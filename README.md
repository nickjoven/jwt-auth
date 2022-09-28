# AUTH

bcrypt does most of the heavy lifting. It encrypts passwords and gives you a method called authenticate.
bcrypt needs a password_digest column.

## Steps:

- Uncomment the bcrypt gem in the gemfile && bundle install
- Tell methods to try :authenticate, e.g. login -> find user and authenticate

## Why do we authenticate?

Proper authentication means hiding sensitive information. POST methods depend on a user id, for instance. If anyone can make a POST request with any ID, your users are at risk of impersonation. You can use JWT to hide the user id in a token.

## JWT

JWT takes a payload and converts it into a string (encoding), and vice versa (decoding).

Encode takes in a user ID and returns a JWT encoded token.
Deccode takes in a token and returns the user ID.

```
curl -X POST -H "Content-Type: application/json" http://localhost:8000/users -d '{"email": "test", "password": "123"}'

curl -X POST -H "Content-Type: application/json" http://localhost:8000/login -d '{"email": "test", "password": "123"}'

curl -X POST -H "Content-Type: application/json" http://localhost:8000/posts -d '{"content": "TEST", "user_id": 1}'

curl -X GET -H "Content-Type: application/json" -H "token: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.kK4OImFfNUEiTyj5uGl00buwlyITPJQHKBzpeRH6lOM" http://localhost:8000/profile

curl -X POST -H "Content-Type: application/json" -H "token: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.kK4OImFfNUEiTyj5uGl00buwlyITPJQHKBzpeRH6lOM" http://localhost:8000/posts -d '{"content": "TOKENS HOLY SHIT"}'
```

