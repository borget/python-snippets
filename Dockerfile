# syntax=gcr.io/host-project-f966/dockerfile:1
# Build step
FROM gcr.io/host-project-f966/python-builder-base:v1 AS builder
WORKDIR /component

# TODO: Move this to another repo and place the model in a base image
RUN mkdir -p ./src/models/codes_model
# COPY build/pytorch_model.bin ./src/models/codes_model
COPY requirements.txt .

#   Set variables for python virtual env. https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
ENV VIRTUAL_ENV=/component/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
#   setup python virtual environment ad get packages
RUN rm -rf /component/.venv &&\
    pyvirtinit

          
ENV GOOGLE_APPLICATION_CREDENTIALS="${HOME}/.config/gcloud/application_default_credentials.json"
RUN --mount=type=secret,required=true,id=gcp-creds,target=$GOOGLE_APPLICATION_CREDENTIALS pip install --no-cache-dir -r /component/requirements.txt
RUN pip install --no-cache-dir -r /component/requirements.txt

COPY ./src /component/src

# ENTRYPOINT python3 /component/src/run_predictions.py
