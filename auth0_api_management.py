import json
import requests
from typing import Any
from fastapi import HTTPException
from app.utils.meta_singleton import MetaSingleton


def requires_token(f):
    def decorated(*args, **kwargs):
        Auth0Client().get_access_token()
        return f(*args, **kwargs)

    return decorated


class Auth0Client(metaclass=MetaSingleton):

    def __init__(self):
        self.token = None

    def get_access_token(self):
        url = "https://lumiata.auth0.com/oauth/token"

        payload = json.dumps({
            "client_id": "",
            "client_secret": "",
            "audience": "https://company.auth0.com/api/v2/",
            "grant_type": "client_credentials"
        })
        headers = {
            'Content-Type': 'application/json'
        }

        response = requests.request("POST", url, headers=headers, data=payload)

        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail=response.text)

        self.token = response.json()

    @requires_token
    def get_all_users(self) -> list[dict[Any, Any]]:
        page_limit = 9  # Auth0 limits the number of users you can return (you can only page through the first 1000 items)
        page = 0
        has_next_page = True
        users = []
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.token.get('access_token')}"
        }
        query_params = "per_page=100&include_totals=true&sort=created_at:-1&fields=user_id,email,logins_count,last_login"
        while page < page_limit and has_next_page:
            url = f"https://company.auth0.com/api/v2/users?page={page}&{query_params}"
            response = requests.request("GET", url, headers=headers)

            if response.status_code != 200:
                raise HTTPException(status_code=response.status_code, detail=response.text)

            result = response.json()
            users.extend(result.get("users"))
            page += 1

            if result.get("total") == len(users):
                has_next_page = False

        return users
