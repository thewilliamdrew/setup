#!/bin/zsh

# Install the Intel/Rosetta Homebrew if needed
if [ -f /usr/local/bin/brew ]; then
	echo "2) Found Intel brew"
	alias brow='arch --x86_64 /usr/local/Homebrew/bin/brew'
else
	echo "2) Installing Intel/Rosetta brew and aliasing to brow (old brew)"
	/usr/sbin/softwareupdate --install-rosetta --agree-to-license
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo "alias brow='arch --x86_64 /usr/local/Homebrew/bin/brew'" >> ~/.zshrc
	alias brow='arch --x86_64 /usr/local/Homebrew/bin/brew'
	eval $(brew shellenv)
fi

# Install ITK-SNAP if needed (Intel version)
echo ""
if hash itksnap; then
	echo "3) Found ITK-SNAP"
else
	echo "3) Installing ITK-SNAP"
	brow install --cask itk-snap
	echo 'export PATH=$PATH:/Applications/ITK-SNAP.app/Contents/bin' >> ~/.zshenv
fi

# Install basic utilities
echo ""
echo "4) Installing python and octave as Intel apps for compatibility"
brow upgrade
brow upgrade --cask 
brow install \
  git-annex \
  octave
brow install --cask \
	mambaforge \
	freesurfer

# Set Freesurfer Paths
echo "4b) Checking freesurfer paths"
if hash freeview; then
	echo "4b) Found freesurfer"
else
	echo "4b) Setting freesurfer paths"
	echo 'export FREESURFER_HOME=/Applications/freesurfer' >> ~/.zshenv
	echo 'export SUBJECTS_DIR=$FREESURFER_HOME/subjects' >> ~/.zshenv
	echo 'source $FREESURFER_HOME/SetUpFreeSurfer.sh' >> ~/.zshenv
fi

# Initialize conda for x86
replacement=$(<~/repos/thewilliamdrew/setup/apple-silicon/mambaforge_x86_init)
perl -0777 -i -pe "s/fi # REPLACE WITH mambaforge_x86_init/$replacement/" ~/.zshrc
. ~/.zshrc

# Install FSL if needed
echo ""
if hash fsl; then
	echo "5) Found FSL"
else
	if [ -d "/usr/local/Caskroom/mambaforge/base/envs/py2" ]; then
		echo "5a) Found python2"
		conda activate py2
	else
		echo "5a) Creating a python2 conda environment first"
		conda create --name py2 python=2.7 -y
		conda activate py2
	fi
	echo "5b) Installing FSL (Intel arch)"
	wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py
	python2 fslinstaller.py -d /usr/local/fsl
	rm fslinstaller.py
	echo 'FSLDIR=/usr/local/fsl' >> ~/.zshenv
	echo '. ${FSLDIR}/etc/fslconf/fsl.sh' >> ~/.zshenv
	echo 'PATH=${FSLDIR}/bin:${PATH}' >> ~/.zshenv
	echo 'export FSLDIR PATH' >> ~/.zshenv
	conda deactivate
fi

# Install PALM if needed
echo ""
if hash palm; then
	echo "6) Found PALM"
else
	echo "6) Installing PALM (Intel arch)"
	git clone https://github.com/andersonwinkler/PALM.git ~/repos/PALM
	pushd ~/repos/palm/fileio/@file_array/private
		arch --x86_64 ./compile.sh
	popd
	echo 'export PATH=$PATH:~/repos/PALM' >> ~/.zshenv
fi


# Install NIMLAB conda environment if needed
if [ -d "/usr/local/Caskroom/mambaforge/base/envs/nimlab" ]; then
	echo "7a) Found nimlab conda env"
else
	echo "7a) Building NIMLAB conda environment"
	mamba create -y -n nimlab python=3.9
	conda activate nimlab
	mamba install -y fslpy \
	h5py \
	hdf5 \
	jupyterlab \
	matplotlib \
	ncdu \
	nibabel \
	nilearn \
	numba \
	numpy \
	pandas \
	scikit-learn \
	scipy \
	seaborn \
	sshpass \
	statsmodels \
	tqdm
	
fi

echo "7b) Installing/Updating nimlab python code from github"
if [[ ! -d ~/repos/nimlab ]]; then
	mkdir -p ~/repos/nimlab
fi
pushd ~/repos/nimlab
	gh auth login
	gh repo clone nimlab/software_env
	python -m pip install software_env/python_modules/nimlab
	python -m pip install software_env/python_modules/meta_editor
popd
python -m ipykernel install --user --name nimlab --display-name "Python3.9 (nimlab)"
if [[ ! -d ~/setup ]]; then
	mkdir -p ~/setup
fi
cp -f ~/repos/nimlab/software_env/native_install/mac_config.yaml ~/setup/nimlab_config.yaml

echo ""
echo "	All done!"
echo ""
