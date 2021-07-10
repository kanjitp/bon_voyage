import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String password,
    String name,
    String userName,
    bool isSignUp,
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
  bool _isSignupMode = false;
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

  void _submitLogin() {
    final isValid = _formKey.currentState.validate();
    // retract keyboard
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(_userEmail.trim(), _userPassword, _name, _userName,
          _isSignupMode, context);
      setState(() {
        _isSignupMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      curve: Curves.easeIn,
      height: _isSignupMode ? 400 : 300,
      constraints: BoxConstraints(minHeight: _isSignupMode ? 400 : 300),
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
                          minHeight: _isSignupMode ? 60 : 0,
                          maxHeight: _isSignupMode ? 100 : 0),
                      child: _isSignupMode
                          ? TextFormField(
                              autocorrect: false,
                              enabled: _isSignupMode,
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
                          minHeight: _isSignupMode ? 60 : 0,
                          maxHeight: _isSignupMode ? 100 : 0),
                      child: _isSignupMode
                          ? TextFormField(
                              autocorrect: false,
                              enabled: _isSignupMode,
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
                        child: Text(_isSignupMode ? 'Sign up' : 'Login'),
                        onPressed: () async {
                          _submitLogin();
                        },
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
      ),
    );
  }
}
