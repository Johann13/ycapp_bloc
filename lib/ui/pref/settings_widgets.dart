import 'package:flutter/material.dart';
import 'package:ycapp_bloc/pref/settings_provider.dart';
import 'package:ycapp_bloc/ui/pref/settings_streams.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_future_widgets.dart';
import 'package:ycapp_foundation/ui/loader/base/y_stream_widgets.dart';
typedef Widget SubTitleBuilder<T>(
    BuildContext context, T value, Map<T, String> options);

class SettingsHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  SettingsHeader({@required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
      color: SettingsProvider.of(context).accentColor,
    );
    return ListTile(
      title: Text(
        title,
        style: style,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
            )
          : null,
    );
  }
}

abstract class SettingsWidget<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final String pref;
  final T prefDefault;

  SettingsWidget(
      {Key key,
      @required this.title,
      this.subtitle,
      @required this.pref,
      @required this.prefDefault})
      : super(key: key);
}

class SettingsSwitch extends SettingsWidget<bool> {
  final String depends;
  final bool dependsDefault;
  final String inverseDepends;
  final bool inverseDependsDefault;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  SettingsSwitch({
    Key key,
    @required String title,
    String subtitle,
    @required String pref,
    @required bool prefDefault,
    this.depends,
    this.dependsDefault,
    this.inverseDepends,
    this.inverseDependsDefault,
    this.onChanged,
    this.isDark,
  }) : super(
          key: key,
          title: title,
          subtitle: subtitle,
          pref: pref,
          prefDefault: prefDefault,
        );

  @override
  Widget build(BuildContext context) {
    if (depends != null) {
      return PrefBoolListStream(
        prefs: [pref, depends],
        defaultValues: [prefDefault, dependsDefault],
        builder: (context, prefs) {
          return Opacity(
            opacity: prefs[1] ? 1.0 : 0.5,
            child: SwitchListTile(
              activeColor: Theme.of(context).accentColor,
              title: Text(
                title,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: SettingsProvider.of(context).boolPref.textColor,
                    ),
              ),
              subtitle: subtitle != null
                  ? Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color:
                                SettingsProvider.of(context).boolPref.textColor,
                          ),
                    )
                  : null,
              value: prefs[0],
              onChanged: (value) async {
                if (prefs[1]) {
                  await SettingsProvider.of(context)
                      .boolPref
                      .setPref(pref, value);
                  if (onChanged != null) {
                    onChanged(value);
                  }
                }
              },
            ),
          );
        },
      );
    } else if (inverseDepends != null) {
      return PrefBoolListStream(
        prefs: [pref, inverseDepends],
        defaultValues: [prefDefault, inverseDependsDefault],
        builder: (context, prefs) {
          return Opacity(
            opacity: !prefs[1] ? 1.0 : 0.5,
            child: SwitchListTile(
              activeColor: Theme.of(context).accentColor,
              title: Text(
                title,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: SettingsProvider.of(context).boolPref.textColor,
                    ),
              ),
              subtitle: subtitle != null
                  ? Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color:
                                SettingsProvider.of(context).boolPref.textColor,
                          ),
                    )
                  : null,
              value: prefs[0],
              onChanged: (value) async {
                if (!prefs[1]) {
                  await SettingsProvider.of(context)
                      .boolPref
                      .setPref(pref, value);
                  if (onChanged != null) {
                    onChanged(value);
                  }
                }
              },
            ),
          );
        },
      );
    } else {
      return PrefBoolStream(
        pref: pref,
        defaultValue: prefDefault,
        builder: (context, prefValue) {
          return SwitchListTile(
            activeColor: Theme.of(context).accentColor,
            title: Text(
              title,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: SettingsProvider.of(context).boolPref.textColor,
                  ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color:
                              SettingsProvider.of(context).boolPref.textColor,
                        ),
                  )
                : null,
            value: prefValue,
            onChanged: (value) async {
              await SettingsProvider.of(context).boolPref.setPref(pref, value);
              if (onChanged != null) {
                onChanged(value);
              }
            },
          );
        },
      );
    }
  }
}

class SettingsCheckbox extends StatelessWidget {
  final String title;
  final SubTitleBuilder<bool> subtitle;
  final String pref;
  final bool prefDefault;
  final String depends;
  final bool dependsDefault;
  final ValueChanged<bool> onChanged;
  final Widget leading;

  SettingsCheckbox({
    @required this.title,
    this.leading,
    this.subtitle,
    @required this.pref,
    @required this.prefDefault,
    this.depends,
    this.dependsDefault,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (depends != null) {
      return PrefBoolListStream(
        prefs: [pref, depends],
        defaultValues: [prefDefault, dependsDefault],
        builder: (context, prefs) {
          return Opacity(
            opacity: prefs[1] ? 1.0 : 0.5,
            child: CheckboxListTile(
              //activeColor: YColors.accentColor,
              activeColor: Theme.of(context).accentColor,
              title: Text(title),
              subtitle:
                  subtitle != null ? subtitle(context, prefs[0], null) : null,
              value: prefs[0],
              onChanged: (value) async {
                if (prefs[1]) {
                  await SettingsProvider.of(context)
                      .boolPref
                      .setPref(pref, value);
                  if (onChanged != null) {
                    onChanged(value);
                  }
                }
              },
            ),
          );
        },
      );
    } else {
      return PrefBoolStream(
        pref: pref,
        defaultValue: prefDefault,
        builder: (context, prefValue) {
          return CheckboxListTile(
            activeColor: Theme.of(context).accentColor,
            title: Text(title),
            subtitle:
                subtitle != null ? subtitle(context, prefValue, null) : null,
            value: prefValue,
            onChanged: (value) async {
              await SettingsProvider.of(context).boolPref.setPref(pref, value);
              if (onChanged != null) {
                onChanged(value);
              }
            },
          );
        },
      );
    }
  }
}

class DarkModeSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsSwitch(
      title: 'Dark Mode',
      pref: 'darkMode',
      prefDefault: false,
      onChanged: (value) async {
        if (!value) {
          await SettingsProvider.of(context)
              .boolPref
              .setPref('amoledMode', false);
        }
      },
    );
  }
}

class SettingsPicker extends StatelessWidget {
  final String title;
  final SubTitleBuilder<String> subtitle;
  final Color textColor;
  final String pref;
  final String prefDefault;
  final Map<String, String> options;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  SettingsPicker({
    @required this.title,
    this.subtitle,
    @required this.pref,
    @required this.prefDefault,
    this.textColor,
    this.onChanged,
    this.isDark,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    return PrefStringStream(
      pref: pref,
      defaultValue: prefDefault,
      builder: (BuildContext context, String data) {
        return ListTile(
          title: Text(title),
          subtitle:
              subtitle != null ? subtitle(context, data, null) : Container(),
          isThreeLine: true,
          onTap: () async {
            String v = await showDialog<String>(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Text(title),
                  children: options.keys.map((key) {
                    return SimpleDialogOption(
                      child: ListTile(title: Text(options[key])),
                      onPressed: () {
                        Navigator.pop(context, key);
                      },
                    );
                  }).toList(),
                );
              },
            );
            if (v != null) {
              await SettingsProvider.of(context).stringPref.setPref(pref, v);
            }
          },
        );
      },
    );
  }
}

class SettingsIntPicker extends StatelessWidget {
  final String title;
  final SubTitleBuilder<int> subtitle;
  final Color textColor;
  final String pref;
  final int prefDefault;
  final Map<int, String> options;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  SettingsIntPicker({
    @required this.title,
    this.subtitle,
    @required this.pref,
    @required this.prefDefault,
    this.textColor,
    this.onChanged,
    this.isDark,
    @required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return PrefIntStream(
      pref: pref,
      defaultValue: prefDefault,
      builder: (BuildContext context, int data) {
        return ListTile(
          title: Text(title),
          subtitle:
              subtitle != null ? subtitle(context, data, options) : Container(),
          isThreeLine: true,
          onTap: () async {
            int v = await showDialog<int>(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Text(title),
                  children: options.keys.map((key) {
                    return SimpleDialogOption(
                      child: ListTile(title: Text(options[key])),
                      onPressed: () {
                        Navigator.pop(context, key);
                      },
                    );
                  }).toList(),
                );
              },
            );
            if (v != null) {
              await SettingsProvider.of(context).intPref.setPref(pref, v);
            }
          },
        );
      },
    );
  }
}

class SettingsToggleButton extends StatelessWidget {
  final String title;
  final SubTitleBuilder<String> subtitle;
  final Color textColor;
  final String pref;
  final String prefDefault;
  final Map<String, String> options;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  SettingsToggleButton({
    @required this.title,
    this.subtitle,
    @required this.pref,
    @required this.prefDefault,
    this.textColor,
    this.onChanged,
    this.isDark,
    @required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return PrefStringStream(
      pref: pref,
      defaultValue: prefDefault,
      builder: (BuildContext context, String data) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              if (subtitle != null)
                subtitle != null
                    ? subtitle(context, data, options)
                    : Container(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ToggleButtons(
                  selectedColor: SettingsProvider.of(context).accentColor,
                  splashColor: SettingsProvider.of(context).accentColor[300],
                  fillColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  selectedBorderColor: SettingsProvider.of(context).accentColor,
                  onPressed: (i) {
                    SettingsProvider.of(context)
                        .stringPref
                        .setPref(pref, options.keys.toList()[i]);
                  },
                  children: options.values.map((v) {
                    return Text(v);
                  }).toList(),
                  isSelected: options.keys.map((key) => key == data).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsIntToggleButton extends StatelessWidget {
  final String title;
  final SubTitleBuilder<int> subtitle;
  final Color textColor;
  final String pref;
  final int prefDefault;
  final Map<int, String> options;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  SettingsIntToggleButton({
    @required this.title,
    this.subtitle,
    @required this.pref,
    @required this.prefDefault,
    this.textColor,
    this.onChanged,
    this.isDark,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    return PrefIntStream(
      pref: pref,
      defaultValue: prefDefault,
      builder: (BuildContext context, int data) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              subtitle != null ? subtitle(context, data, options) : Container(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ToggleButtons(
                  selectedColor: SettingsProvider.of(context).accentColor,
                  splashColor: SettingsProvider.of(context).accentColor[300],
                  fillColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  selectedBorderColor: SettingsProvider.of(context).accentColor,
                  onPressed: (i) {
                    SettingsProvider.of(context)
                        .intPref
                        .setPref(pref, options.keys.toList()[i]);
                  },
                  children: options.values.map((v) {
                    return Text(v);
                  }).toList(),
                  isSelected: options.keys.map((key) => key == data).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsPopupButton extends StatelessWidget {
  final String title;
  final SubTitleBuilder<String> subtitle;
  final Color textColor;
  final String pref;
  final String prefDefault;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;
  final bool isDark;

  SettingsPopupButton({
    @required this.title,
    this.subtitle,
    @required this.pref,
    @required this.prefDefault,
    this.textColor,
    this.onChanged,
    this.isDark,
    @required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return PrefStringStream(
        pref: pref,
        defaultValue: prefDefault,
        builder: (BuildContext context, String data) {
          return PopupMenuButton<String>(
            initialValue: data,
            child: ListTile(
              title: Text(title),
              subtitle:
                  subtitle != null ? subtitle(context, data, options) : null,
            ),
            itemBuilder: (context) {
              return options.keys.map((key) {
                return PopupMenuItem<String>(
                  child: ListTile(
                    title: Text(options[key]),
                  ),
                  value: key,
                );
              }).toList();
            },
            onSelected: (key) async {
              await SettingsProvider.of(context).stringPref.setPref(pref, key);
              if (onChanged != null) {
                onChanged(key);
              }
            },
          );
        });
  }
}

class SettingsIntPopupButton extends StatelessWidget {
  final String title;
  final SubTitleBuilder<int> subtitle;
  final Color textColor;
  final String pref;
  final int prefDefault;
  final Map<int, String> options;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  SettingsIntPopupButton({
    @required this.title,
    this.subtitle,
    @required this.pref,
    @required this.prefDefault,
    this.textColor,
    this.onChanged,
    this.isDark,
    @required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return PrefIntStream(
      pref: pref,
      defaultValue: prefDefault,
      builder: (BuildContext context, int data) {
        return PopupMenuButton<int>(
          child: ListTile(
            title: Text(title),
            subtitle:
                subtitle != null ? subtitle(context, data, options) : null,
          ),
          itemBuilder: (context) {
            return options.keys.map((key) {
              return PopupMenuItem<int>(
                child: ListTile(title: Text('${options[key]}')),
                value: key,
              );
            }).toList();
          },
          onSelected: (key) {
            SettingsProvider.of(context).intPref.setPref(pref, key);
          },
        );
      },
    );
  }
}

class TimePrefWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String usePref;
  final bool usePrefDefaultValue;
  final String startH;
  final String startM;
  final int startHDefault;
  final int startMDefault;

  const TimePrefWidget({
    Key key,
    @required this.title,
    @required this.subTitle,
    @required this.usePref,
    @required this.startH,
    @required this.startM,
    this.usePrefDefaultValue = true,
    this.startHDefault = 0,
    this.startMDefault = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrefBoolStream(
      pref: usePref,
      defaultValue: usePrefDefaultValue,
      builder: (context, useMuteTime) {
        return YStreamListBuilder<int>(
          stream: SettingsProvider.of(context).intPref.getMultiplePrefsStream(
              [startH, startM], [startHDefault, startMDefault]),
          builder: (context, value) {
            TimeOfDay init = TimeOfDay(hour: value[0], minute: value[1]);
            return Opacity(
              opacity: useMuteTime ? 1.0 : 0.5,
              child: ListTile(
                title: Text(title),
                subtitle: Text('$subTitle${init.format(context)}'),
                onTap: () async {
                  if (!useMuteTime) {
                    return;
                  }
                  TimeOfDay timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: value[0], minute: value[1]),
                  );
                  if (timeOfDay != null) {
                    print('${timeOfDay.hour}:${timeOfDay.minute}');
                    await SettingsProvider.of(context).intPref.setMultiplePrefs(
                        [startH, startM], [timeOfDay.hour, timeOfDay.minute]);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
