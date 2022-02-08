# Example: ./pyvirtinit $HOME/.

PYTHON_GCP_REPO="https://us-central1-python.pkg.dev/gcs_project_id/repo_name"

# Check python version
PYTHON_EXEC=python3
PYTHON_VERSION=`$PYTHON_EXEC -c 'import sys; print("".join(map(str, sys.version_info[0:2])))'`
if [ $PYTHON_VERSION -lt 37 ]; then 
        PYTHON_EXEC=python3.7
fi

# check again.
PYTHON_VERSION=`$PYTHON_EXEC -c 'import sys; print("".join(map(str, sys.version_info[0:2])))'`
if [ $PYTHON_VERSION -lt 37 ]; then 
	echo "!!!! - requires python3 >3.7. Perhaps it is in /usr/local/bin?"; 
	exit 1
fi

# get virenv path
VIRTUAL_ENV=$1
if [ "$VIRTUAL_ENV" = "" ]; then
    # no directory was specified
    VIRTUAL_ENV="$PWD"
else
    # Mac OS does not have real path
    VIRTUAL_ENV=`python -c 'import os, sys; print(os.path.realpath("'$VIRTUAL_ENV'"))'`    
fi
VIRTUAL_ENV="$VIRTUAL_ENV/.venv"
if [ -d "$VIRTUAL_ENV" ]; then
	echo "!!!! - $VIRTUAL_ENV exist. To activate run: \n    source $VIRTUAL_ENV/bin/activate"
        exit 1
fi

# Create full path
echo "  Creating venv:  $VIRTUAL_ENV"
$PYTHON_EXEC -m venv $VIRTUAL_ENV
if [ $? -ne 0 ]; then
    echo "    !!!! - Is directory valid: $VIRTUAL_ENV"
    exit 1
fi

# install keyring/twine
OLDPATH=$PATH
export PATH=$VIRTUAL_ENV/bin:$PATH
echo "  Updating pip"
pip install -q --no-cache-dir -U pip 
echo "  Installing wheel"
pip install -q wheel --no-cache-dir
echo "  Installing keyring"
pip install -q keyring --no-cache-dir
echo "  Installing google keyring module"
pip install -q keyrings.google-artifactregistry-auth --no-cache-dir
echo "  Installing twine."
pip install -q twine --no-cache-dir
export PATH=$OLDPATH

# Copy over pypirc (twine) and pip.conf (pip) configuration
cat >$VIRTUAL_ENV/pypirc<<EOL
[distutils]
index-servers =
    lumiata

[lumiata]
repository: ${PYTHON_GCP_REPO}
EOL

cat >$VIRTUAL_ENV/pip.conf<<EOL
[global]
extra-index-url = ${PYTHON_GCP_REPO}/simple/
EOL


# Inject some specific in activate script
APP_DIR=`dirname $VIRTUAL_ENV`
APP_DIR=`basename $APP_DIR`
cat >>$VIRTUAL_ENV/bin/activate<<EOL

# Added by virt-env-create
#     Update twine configuration.
ln -sf $VIRTUAL_ENV/pypirc $HOME/.pypirc
#     Update PS1 variable.
if [ -z "\${VIRTUAL_ENV_DISABLE_PROMPT:-}" ] ; then
   PS1=\${PS1#\(}
   PS1="(${APP_DIR}/\${PS1}"
fi
EOL

echo "  Python virtual environment created. To activate run:"
echo "    \". $VIRTUAL_ENV/bin/activate\""
