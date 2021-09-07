import 'package:flutter/material.dart';

import '../../screens/auth_screen.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String password,
    String name,
    String userName,
    AuthMode mode,
    BuildContext context,
  ) submitFn;

  final isLoading;

  AuthForm(this.submitFn, this.isLoading, {Key key}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AnimationController _animationController;
  AuthMode _mode = AuthMode.logIn;
  String _userEmail = '';
  String _name = '';
  String _userName = '';
  String _userPassword = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // clean the listener
    _animationController.dispose();
  }

  void _submitLogin() async {
    final isValid = _formKey.currentState.validate();
    // retract keyboard
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();

      await widget.submitFn(
          _userEmail.trim(), _userPassword, _name, _userName, _mode, context);
    }

    setState(() {
      if (_mode == AuthMode.signUp) {
        // change mode to log in for the user for convenience
        _mode = AuthMode.logIn;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      curve: Curves.easeIn,
      height: _mode == AuthMode.signUp
          ? 500
          : _mode == AuthMode.logIn
              ? 400
              : 300,
      constraints: BoxConstraints(
          minHeight: _mode == AuthMode.signUp
              ? 500
              : _mode == AuthMode.logIn
                  ? 400
                  : 300),
      width: mediaQuery.size.width,
      child: Center(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 20,
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
                      autocorrect: false,
                      key: ValueKey('email'),
                      validator: (input) {
                        if (input.isEmpty || !input.contains('@')) {
                          return 'Please enter a valid email address';
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email address",
                        hintText: "email@domain.com",
                      ),
                      onSaved: (value) {
                        _userEmail = value;
                      },
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 350),
                      curve: Curves.easeIn,
                      constraints: BoxConstraints(
                          minHeight: _mode == AuthMode.signUp ? 60 : 0,
                          maxHeight: _mode == AuthMode.signUp ? 100 : 0),
                      child: _mode == AuthMode.signUp
                          ? TextFormField(
                              autocorrect: false,
                              enabled: _mode == AuthMode.signUp,
                              key: ValueKey('name'),
                              validator: (input) {
                                if (input.isEmpty || input.length < 4) {
                                  return 'name must be at least 4 characters long';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                  labelText: 'Name',
                                  hintText: "FirstName LastName"),
                              onSaved: (value) {
                                _name = value;
                              },
                            )
                          : null,
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 350),
                      curve: Curves.easeIn,
                      constraints: BoxConstraints(
                          minHeight: _mode == AuthMode.signUp ? 60 : 0,
                          maxHeight: _mode == AuthMode.signUp ? 100 : 0),
                      child: _mode == AuthMode.signUp
                          ? TextFormField(
                              autocorrect: false,
                              enabled: _mode == AuthMode.signUp,
                              key: ValueKey('username'),
                              validator: (input) {
                                if (input.isEmpty || input.length < 4) {
                                  return 'Username must be at least 4 characters long';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                  labelText: 'Username',
                                  hintText: "your_username"),
                              onSaved: (value) {
                                _userName = value;
                              },
                            )
                          : null,
                    ),
                    if (_mode != AuthMode.forgotPassword)
                      TextFormField(
                        autocorrect: false,
                        key: ValueKey('password'),
                        validator: (input) {
                          if (input.isEmpty || input.length < 7) {
                            return 'Password must be at least 8 characters long';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: "at least 8 characters long"),
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
                        child: Text(_mode == AuthMode.signUp
                            ? 'Sign up'
                            : _mode == AuthMode.logIn
                                ? 'Login'
                                : 'Send password reset link'),
                        onPressed: () async {
                          _submitLogin();
                        },
                      ),
                    if (!widget.isLoading)
                      FlatButton(
                        child: Text(_mode == AuthMode.signUp
                            ? 'I already have an account'
                            : _mode == AuthMode.logIn
                                ? 'Create new account'
                                : 'Cancel'),
                        onPressed: () {
                          setState(() {
                            if (_mode == AuthMode.logIn) {
                              _mode = AuthMode.signUp;
                            } else {
                              _mode = AuthMode.logIn;
                            }
                          });
                        },
                        textColor: Theme.of(context).splashColor,
                      ),
                    if (_mode != AuthMode.forgotPassword)
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            _mode = AuthMode.forgotPassword;
                          });
                        },
                        child: Text(
                          'Fogotten password?',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.w300),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
