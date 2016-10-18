## Installation
Install with:

```
gem install gisterday 
```

## Usage
Create Gists via the command line from existing files or on the fly. Authenticate with your GitHub account in order to store these Gists for later. 

* Use `gist [filename]` in order to create a new anonymoust gist. 
* If the file exists in the current directory, it will be pushed to a new Gist. 
* If the file does not exist, Vim will be opened so the file can be created.

### Examples
Open Vim in order to write a new Gist from scratch
```ruby
gist 
```

Create a gist with the description "set a description", upload it anonymously, and create the gist using the contents of myfile.rb
Alternatively, if `myfile.rb` does not exist, Vim will be opened to edit a new file called `myfile.rb`
```ruby
gist -d "set a description" -a myfile.rb
```

## Logging In
* Use `gist login` to authenticate with your GitHub account.
* A personal access token will be created and stored in `~/.gisterday` for access on subsequent uses of Gisterday. 

## Options
* Use the flag `-a` to create the gist anonymously (skip auth). Note that unless a personal access token is stored in `~/.gisterday` all Gists will be created anonymously.
* Use the flag `-d` to set a description for the Gist.
* Use the flag `-v` for a more verbose http response with the full response body.

