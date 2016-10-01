Usage
* Use `gist [filename]` in order to create a new anonymoust gist. 
* If the file exists, it will be pushed to a new Gist. 
* If the file does not exist, one can be created using Vim.

Logging In
* Use `gist login` to authenticate into your GitHub account.
* A personal access token will be stored in an environment varialbe to sign future requests.

Options
* Use the flat `-a` to create the gist anonymously (skip auth).
* Use the flag `-d` to set a description for the gist.
* Use the flag `-v` for a more verbose http response with the full response body.

Still to come
* A user can search and edit their existing gists.