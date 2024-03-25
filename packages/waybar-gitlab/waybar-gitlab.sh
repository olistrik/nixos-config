#!/bin/sh

# shellcheck source=/dev/null
source "${HOME}/.config/waybar-gitlab/config"

function query () {
	document="$(cat)"
	document=${document//$'\n'/}
	document=${document//$'"'/\\\"}
	curl "${GITLAB_URL}/api/graphql" --header "Authorization: Bearer ${ACCESS_TOKEN}" \
		--header "Content-Type: application/json" --request POST  -s \
		--data "{\"query\": \"${document}\"}"
}

issues () {
	query <<-EOF | jq .data.group.issues.count | echo "  $(cat)"
	query {
		group (fullPath: "${GROUP_PATH}") { 
			issues(state: opened) {
				count
			}
		}
	}
	EOF
}

mergeRequests() {
	query <<-EOF | jq .data.group.mergeRequests.count | echo "  $(cat)"
	query {
		group (fullPath: "${GROUP_PATH}") { 
			mergeRequests(state: opened) {
				count
			}
		}
	}
	EOF
}

fn=""
if [[ $1 == "issues" ]]; then
  if [[ $# == 2 ]] && [[ $2 == "open" ]]; then
    xdg-open "${GITLAB_URL}/groups/${GROUP_PATH}/-/issues"
    exit 0
  fi
	fn=issues
elif [[ $1 == "merge-requests" ]]; then
  if [[ $# == 2 ]] && [[ $2 == "open" ]]; then
    xdg-open "${GITLAB_URL}/groups/${GROUP_PATH}/-/merge_requests"
    exit 0
  fi
	fn=mergeRequests
else 
	exit 1
fi

while true; do
	cat <<-EOF | jq --compact-output --unbuffered
	{
		"text": "$(${fn})",
		"class": "gitlab-${1}"
	}
	EOF
	sleep 10
done
