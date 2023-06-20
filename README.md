# enversh
a sample fake environment manager, cross compatibility wrapper for many linux distros.

# Requirements
- [bash](https://github.com/user/repository.git)
- [coreutils](https://github.com/user/repository.git)
- [jq](https://github.com/user/repository.git)

# Installation
```bash
set -e
git clone https://github.com/lazypwny751/enversh.git
cd enversh
make install # require root privalages.
```

# Usage
```
Why we need "enversh.sh", Although rare, the environment 
elements may vary between different distributions,
so a virtual environment that you will prepare 
in json format is configured to be adjusted in
the distributions you specify, and it will also
bring the packages you specify.

usage of enversh.sh, there is 7 arguments:
bash enversh.sh --soft:
	this is the default linking method of enversh.sh,
	it links all the exports as soft link.
bash enversh.sh --hard:
	this method links all the exports as hard link but
	it could be required root privalages.
bash enversh.sh --force:
	if any command not found, replace it with any null bash script.
bash enversh.sh --require:
	install all of packages that given file via supported distributions.
bash enversh.sh --path <path>:
	set the current path directory, it will be created if doesn't exist
	and all the exports goes there.
bash enversh.sh --help:
	show's this helper output.
bash enversh.sh --version: 
	show's current version of the script (1.0.0).
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[GPL3](https://choosealicense.com/licenses/gpl-3.0/)