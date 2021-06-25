import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String password,
    String userName,
    bool isSignUp,
    BuildContext context,
  ) submitFn;

  final isLoading;

  AuthForm(this.submitFn, this.isLoading, {Key key}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSignupMode = false;
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';

  void _submitLogin() {
    final isValid = _formKey.currentState.validate();
    // retract keyboard
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
          _userEmail.trim(), _userPassword, _userName, _isSignupMode, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: ValueKey('email'),
                    validator: (input) {
                      if (input.isEmpty || !input.contains('@')) {
                        return 'Please enter a valid email address';
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: "Email address"),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  if (_isSignupMode)
                    TextFormField(
                      key: ValueKey('username'),
                      validator: (input) {
                        if (input.isEmpty || input.length < 4) {
                          return 'Username must be at least 4 characters long';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(labelText: 'Username'),
                      onSaved: (value) {
                        _userName = value;
                      },
                    ),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: (input) {
                      if (input.isEmpty || input.length < 7) {
                        return 'Password must be at least 8 characters long';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(labelText: 'Password'),
                    onSaved: (value) {
                      _userPassword = value;
                    },
                    obscureText: true,
                    obscuringCharacter: '※',
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    RaisedButton(
                      child: Text(_isSignupMode ? 'Sign up' : 'Login'),
                      onPressed: _submitLogin,
                    ),
                  if (!widget.isLoading)
                    FlatButton(
                      child: Text(_isSignupMode
                          ? 'I already have an account'
                          : 'Create new account'),
                      onPressed: () {
                        setState(() {
                          _isSignupMode = !_isSignupMode;
                        });
                      },
                      textColor: Theme.of(context).splashColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
