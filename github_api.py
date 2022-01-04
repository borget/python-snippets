import requests
import json

username = 'alberto-tletl'

# from https://github.com/settings/tokens
token = 'ghp...sal'

releases_url = 'https://api.github.com/repos/lumiata/ai-studio/releases'

# create a re-usable session object with the user creds in-built
gh_session = requests.Session()
gh_session.auth = (username, token)

releases = json.loads(gh_session.get(releases_url).text)

for release in releases:
    print(release['name'])
