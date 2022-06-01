
![banner](./misc/banner.svg)

___

Linear submodule count increase is generally accompanied by an exponential growth of headache: Keeping Git submodules up to date is monotonous and — more importantly — _interruptive_ work. Managing your dependencies shouldn't keep you from being productive! Matryoshka can automate your submodule updates and enable you to run them without losing focus of your _real_ task:

![demo-gif](https://geeky.gent/misc/matryoshka_demo.gif)


**Disclaimer: Use at your own risk. I cannot be held responsible for data loss.**

If you encounter any trouble though, **please let me know**


## Installation & Setup

### Setup Matryoshka locally

1. Clone the repository
2. Enter `matryoshka` and grant scripts permissions to be executed:
```bash
$ chmod +x *.sh
```

3. Assure your Git submodules are setup properly and these commands have been run at least once since adding your latest modules:
```bash
$ git submodule init
$ git submodule update
```

4. *Optional:* I prefer to have this script ready at all times without manually typing out its path. I suggest [creating an `alias` within your `.bashrc`](https://www.cyberciti.biz/faq/create-permanent-bash-alias-linux-unix/):
```bash
# Add this inside your shell's rc file:
alias MATRYOSHKA="path/to/matryoshka/matryoshka.sh"
```
Depending on your setup you may have to restart / reload your shell afterwards.


### Setup as submodule

To enable your colleagues to access the script right within your repository, add it _as a submodule_:

```bash
# Optional — Containing Subdirectory
$ mkdir tools
$ cd tools

# Check your staging area for uncommit changes, the following changes
# will be staged automatically:
$ git submodule add https://github.com/t89/matryoshka.git matryoshka
$ git submodule update --init

$ git commit -m "Add Matryoshka submodule"

```


## Run

1. Enter your repo directory and call the script `bash path/to/matryoshka.sh` (or use the more convenient `alias`)

2. You are presented with a list of available submodules. Select all or a specific one.

3. Decide if you would just like to update and leave the changes **unstaged and uncommitted** or generate a commit for each updated submodule individually.

## Options

* Use `-a` option to preselect `all` in the selection of submodules.
* Use `-c` to preselect the auto commit mode.
* Use `-m "My update message"` to specify the text of the commit message. The `<submodule>` and `<hash>` placeholders within the string will be replaced with their respective values.


## How does auto-commit work?

1. Matryoshka checks if the working directory is dirty
  - If it is dirty a stash will be created with an attached message: `"Submodule update <date>"`
  - The hash of this stash will be printed for you. If anything goes wrong, you can always grab your changes using this hash.
2. Iterate through submodules, creating a dedicated commit for each (updated) module. The commit-msg follows the following style: `"Update <submodule_name> to <shortened_hash>"`.
3. Popping the stash


## Authors

* **Thomas Johannesmeyer** - [www.geeky.gent](http://geeky.gent)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Support

The framework and code are provided as-is, but if you need help or have suggestions, you can contact me anytime at [opensource@geeky.gent](mailto:opensource@geeky.gent?subject=Matryoshka).


## I'd like to hear from you

If you have got any suggestions, please feel free to share them with me. :)
