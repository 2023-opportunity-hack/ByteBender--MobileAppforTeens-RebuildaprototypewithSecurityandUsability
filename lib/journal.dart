import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Journal extends StatefulWidget {
  String phone;
  Journal(this.phone);

  @override
  _JournalState createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(4280758332),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50.0,
            left: 10,
            right: 10,
          ),
          child: Column(children: [
            Text(
              "Drop in your worries to find solutions !",
              style: TextStyle(
                  fontSize: 19,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: TextField(
                controller: _queryController,
              ),
            ),
            GestureDetector(
              onTap: () {
                FirebaseFirestore.instance.collection("Journal").add({
                  "message": _queryController.text,
                  "phone": widget.phone,
                });
                _queryController.clear();
              },
              child: Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.blue),
                child: Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Send",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("Journal").snapshots(),
              builder: (context, snapshot) {
                return snapshot.data == null
                    ? Container()
                    : ListView.separated(
                        separatorBuilder: (ctx, i) {
                          return SizedBox(
                            height: 20,
                          );
                        },
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (ctx, i) {
                          var data = snapshot.data?.docs[i].data;

                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.blue.withOpacity(0.3)),
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                          "https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg"),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      data!()["phone"] == widget.phone
                                          ? "You"
                                          : "Anonymous",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    data()["message"],
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
              },
            )
          ]),
        ),
      ),
    );
  }
}
class SimpleTextField extends StatefulWidget {
  const SimpleTextField({
    required this.onChanged,
    required this.textEditingController,
    required this.autofillHints,
    required this.textInputType,
    this.autoFocus = false,
    this.obscureText = false,
    required this.textInputAction,
    required this.focusNode,
    required this.prefixIconData,
    required this.hintText,
    required this.labelText,
    required this.errorText,
    required this.helperText,
    this.showLabelAboveTextField = false,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    required this.fillColor,
    required this.accentColor,
    this.textColor = Colors.black,
    this.borderRadius = 6,
    required this.validator,
    this.showConfirmation = true,
    this.showError = true,
    this.verticalPadding = 20,
    this.horizontalPadding = 12,
  });

  final Function(String) onChanged;
  final TextEditingController textEditingController;
  final Iterable<String> autofillHints;
  final TextInputType textInputType;
  final bool autoFocus;
  final bool obscureText;
  final TextInputAction textInputAction;
  final FocusNode focusNode;
  final IconData prefixIconData;
  final String hintText;
  final String labelText;
  final String errorText;

  /// Text placed below the text field
  final String helperText;
  final bool showLabelAboveTextField;
  final FloatingLabelBehavior floatingLabelBehavior;
  final Color fillColor;
  final Color accentColor;
  final Color textColor;
  final double borderRadius;
  final bool Function(String) validator;
  final bool showConfirmation;
  final bool showError;
  final double verticalPadding;
  final double horizontalPadding;

  @override
  _SimpleTextFieldState createState() => _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<SimpleTextField> {
  late FocusNode focusNode;
  late TextEditingController textEditingController;
  late bool hasConfirmation;
  late bool hasError;
  late bool hasFocus;

  @override
  void initState() {
    super.initState();
    hasFocus = false;
    textEditingController = widget.textEditingController != null
        ? widget.textEditingController
        : TextEditingController();
    hasConfirmation = textEditingController.text != null ? isValid : false;
    hasError = textEditingController != null ? !isValid : false;
    focusNode = widget.focusNode != null ? widget.focusNode : FocusNode();

    focusNode.addListener(() {
      setState(() {
        hasFocus = focusNode.hasPrimaryFocus;
        bool valid = isValid;
        hasConfirmation = valid;
        hasError = !valid;
      });
    });
  }

  bool get isValid {
    if (hasValidator) {
      return widget.validator(textEditingController.text);
    }
    return false;
  }

  bool get hasValidator {
    return widget.validator != null;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);

    OutlineInputBorder buildFocusedBorder() {
      if (hasValidator) {
        if (hasConfirmation && widget.showConfirmation) {
          return OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 1.25),
              borderRadius: BorderRadius.circular(widget.borderRadius));
        } else if (hasError) {
          return OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.25),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          );
        }
      }
      return OutlineInputBorder(
        borderSide: BorderSide(
            color: widget.accentColor ?? currentTheme.primaryColor,
            width: 1.25),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      );
    }

    OutlineInputBorder buildEnabledBorder() {
      if (hasValidator) {
        if (hasConfirmation) {
          return OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          );
        } else if (hasError) {
          return OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          );
        }
      }
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
        ),
      );
    }

    TextStyle? buildLabelStyle() {
      if (hasFocus) {
        return TextStyle(color: widget.accentColor);
      } else {
        return null;
      }
    }

    Icon? buildSuffixIcon() {
      if (hasValidator) {
        if (hasConfirmation) {
          return Icon(Icons.check, color: Colors.green);
        } else if (hasError) {
          return Icon(
            Icons.error,
            color: Colors.red,
            size: 24,
          );
        }
      }
      return null;
    }

    return TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionColor: widget.accentColor?.withOpacity(.33) ??
            currentTheme.primaryColor.withOpacity(.33),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null && widget.showLabelAboveTextField) ...[
            Text(
              widget.labelText,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 6),
          ],
          TextField(
            focusNode: focusNode,
            controller: textEditingController,
            autofillHints: widget.autofillHints,
            keyboardType: widget.textInputType,
            autofocus: widget.autoFocus,
            maxLines: 3,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            onChanged: (val) {
              setState(() {
                hasError = false;
                hasConfirmation = isValid;
              });
              if (widget.onChanged != null) {
                widget.onChanged(val);
              }
            },
            cursorColor: Colors.white,
            obscureText: widget.obscureText,
            textInputAction: widget.textInputAction,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  vertical: widget.verticalPadding,
                  horizontal: widget.horizontalPadding),
              isDense: true,
              hintText: widget.hintText,
              hintStyle: TextStyle(color: widget.textColor.withOpacity(.45)),
              labelText:
                  widget.showLabelAboveTextField ? null : widget.labelText,
              labelStyle: buildLabelStyle(),
              errorText: widget.errorText != null && hasError && hasValidator
                  ? widget.errorText
                  : null,
              floatingLabelBehavior: widget.floatingLabelBehavior,
              fillColor: widget.fillColor,
              filled: widget.fillColor != null,
              focusedBorder: buildFocusedBorder(),
              enabledBorder: buildEnabledBorder(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              prefixIcon: widget.prefixIconData != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 8),
                      child: Icon(
                        widget.prefixIconData,
                        color: hasFocus
                            ? widget.accentColor
                            : widget.textColor.withOpacity(.6),
                        size: 20,
                      ),
                    )
                  : null,
              prefixIconConstraints:
                  BoxConstraints(minHeight: 24, minWidth: 24),
              suffixIcon: buildSuffixIcon(),
            ),
          ),
          if (widget.helperText != null) ...[
            SizedBox(height: 6),
            Text(
              widget.helperText,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            )
          ]
        ],
      ),
    );
  }
}
