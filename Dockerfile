FROM python:3.13-rc-alpine3.19
LABEL maintainer="cushcoding.co.za"

#This tells us that we want python output to go directly to console
ENV PYTHONUNBUFFERED 1 

#Copy local to docker image
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

COPY ./app /app
# Setting directory where commands are run from
WORKDIR /app

EXPOSE 8000

#defines a build argument and sets it to false
ARG DEV=false
# create environment
# upgrade pip in the venv
# install the requirements file
# remove tmp directory - best practice 
# add user inside image - best practice to not use the root
# no password because we don't need it
# no create home to keep lightweight

# apk add installs postgres client
# apk with virtual option, sets virtual dependency package and groups them together
# list the build packages
# remove temp build deps
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
      build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
      then /py/bin/pip install -r /tmp/requirements.dev.txt ;\
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
      --disabled-password \
      --no-create-home \
      django-user

# PATH environment variable defines all of the directories where executables can be run
ENV PATH="/py/bin:$PATH"

# specifies the user we are switching to
USER django-user