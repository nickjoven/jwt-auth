
# Rails Authentication with JWT

Continuing along with blog website examples, a basic `create` method for a blog post might look like this:

```ruby
# POST /posts
def create
    post = Post.create!(post_params)
    render json: post
end

private

def post_params
    params.permit(:title, :content, :user_id)
end
```

with a corresponding route:

```ruby
post '/posts', to: 'posts#create'
```

And from here, you would expect that sending a post request from your front end (grabbing `title` and `content` from input fields, and `user_id` from the currently logged in user) should create a blog post (pending validations and all).

Unfortunately, a *malicious user* could open up the dev tools in their browser, look at the network tab, inspect the requests that are going back and forth, and notice that they could easily create a blog post as *any user* by making a request with a different `user_id`.

If you have *zero* security measures in place, your user passwords are probably also insecure. If you don't want `get '/users', to:` `EXPOSE EVERYONE'S PASSWORD` then you should probably implement some encryption.

So, let's encrypt and authenticate.

## TLDR; bcrypt and JWT

### Password encryption

Start by hiding those passwords with bcrypt. [docs](https://www.rubydoc.info/gems/bcrypt-ruby/)

1. Make sure your Rails app has bcrypt installed.
   1. It's already in the gemfile in a new Rails app, but you need to uncomment out the line 
   ```ruby
   gem "bcrypt", "~> 3.1.7"
   ```
    in the gemfile. And run `bundle install`, of course.

2. If you have a `password` column, change it to a `password_digest` column. Or do that when you generate a model that has a a secure password.

3. In a controller (you can make a separate Auth controller, or put this in the Users controller), implement bcrypt's built-in `authenticate` method.

Here's an example using `.try`. You could just as well use `if` `&&` or `&.`, syntactically speaking. 

```ruby
# POST /login   
def login
    user = User.find_by!(email: params[:email]).try(:authenticate, params[:password])
    if user
        render json: user
    else
        render json: { error: "Invalid Password"}, status: 401
    end
end
  ```

Find out what `:authenticate` does in the Rails [bcrypt docs](https://www.rubydoc.info/gems/bcrypt-ruby/). If you wish.

### Tokens. Local Storage. JWT.

Now that the passwords have been fixed up, we want to use something called `local storage` to give a browser the ability to remember a user, and use that memorized user to make secure requests to the server. `JSON WEB TOKENS`

1. Install `jwt` with `gem install jwt` or putting `gem jwt` in your gemfile and running bundle install. **REMEMBER TO STOP AND START YOUR SERVER HEREABOUTS**
2. Toss these methods into your `app/controllers/application_controller.rb` file.
```ruby
def get_secret_key 
# in production your secret key should be a variable in a .env file that is not visible on github 
# (but who remembers how to do that)
    "123"
end

def generate_token(user_id)
    JWT.encode({user_id:user_id}, get_secret_key)
end

def decode_token(token)
    JWT.decode(token, get_secret_key)[0]["user_id"]
end  
```

You want your other controllers to have access to these methods. You also may want to rescue from JWT-related errors here, but that's another lesson for `<after I learn how to do that>`. 

3. Use these methods in your controllers to replace plain old `user_id`s.

Example:

```ruby
  # POST /login
def login
    user = User.find_by!(email: params[:email]).try(:authenticate, params[:password])
    if user
        token = generate_token(user.id)
        render json: { user: user, token: token }
    else
        render json: { error: "Invalid Password"}, status: 401
    end
end
```

```ruby
  # POST /posts
def create
    token = request.headers["token"]
    user_id = decode_token(token)
    post = Post.create!(title: params[:title], content: params[:content], user_id: user_id) # note that the user_id here comes from the decoded token, rather than the params
    render json: post, status: 201
end
```

### What is Actually Happening

Check out this [repo](https://github.com/mustafabin/jwt-rails) from [Mustafa](https://www.linkedin.com/in/mustafa-binalhag-5080bb157/) to see a basic implementation of the JWT tokens with a front end login request.

[https://github.com/mustafabin/jwt-rails](https://github.com/mustafabin/jwt-rails)

Here's the deal. 

- When a user successfully logs in, the `login` route renders a user (as expected) and a token created from the `generate_token` method.
- The front end performs `localStorage.setItem("jwt", data.token)` (data is whatever variable name you're using in your fetch for the .json()'ed response)
- For any controller methods that have `token = request.headers["token"]`, the front end now needs to send a token in the headers. As part of such fetch requests, you will likely grab the token from local storage with `let token = localStorage.getItem("jwt")` and include `token: token,` in the headers object.

## When does the token expire? What is local storage? What is setItem and getItem?

[https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage)


## Further Reading

[Local Storage vs Session Storage vs Cookie](https://www.xenonstack.com/insights/local-vs-session-storage-vs-cookie)

[JWT how does it work and is it secure?](https://dev.to/darken/jwt-how-does-it-work-and-is-it-secure-37n)


### Testing with curl/Postman

Take the token you get from logging in (or any route that gives you a token) and include it in the headers for routes that need a token.

Example:

```
curl -X POST -H "Content-Type: application/json" -H "token: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.kK4OImFfNUEiTyj5uGl00buwlyITPJQHKBzpeRH6lOM" http://localhost:3000/posts -d '{"content": "TOKENS@@@@@@"}'
```






