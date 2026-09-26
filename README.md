# Elvish support for Notepad++

User Defined Language (UDL) files and related configuration for editing [Elvish](https://github.com/elves/elvish) scripts in Notepad++.

## Features

- Syntax highlighting for Elvish keywords, builtins, variables, strings, numbers, comments, and operators.
- Autocompletion entries for Elvish builtins and special variables.
- A Function List parser for `fn` declarations.
- A sample `.elv` script to check the setup.

## Install

### CollectionInterface plugin

The CollectionInterface plugin installs UDLs listed in the official [Notepad++ User Defined Languages Collection](https://github.com/notepad-plus-plus/userDefinedLanguages). To install Elvish this way, this UDL must first be accepted into that collection; it is not listed there yet.

Once Elvish is available in the collection:

1. In Notepad++ 8.8.1 or newer, open **Plugins > Plugins Admin**, find **CollectionInterface**, select it, and click **Install**.
2. Restart Notepad++, then open **Plugins > CollectionInterface > CollectionInterface: Download**.
3. In the **UDL** tab, select **Elvish**. Select the associated AutoCompletion and FunctionList options if offered.
4. Click **Download**, wait for it to finish, then restart Notepad++ when prompted.

For details on adding a UDL to the official collection, see its [contribution guide](https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/CONTRIBUTING.md).

### Manual install

1. In Notepad++, open **Language > User Defined Language > Define your language...**.
2. Select **Import...** and choose [`UDLs/Elvish_byHoangLong.xml`](UDLs/Elvish_byHoangLong.xml).
3. Restart Notepad++ if needed, then open an `.elv` file. Choose **Language > Elvish** if it is not selected automatically.
4. To enable autocompletion, copy [`autoCompletion/Elvish.xml`](autoCompletion/Elvish.xml) into Notepad++'s `autoCompletion` folder and restart Notepad++.
5. To enable the Function List parser, add [`functionList/Elvish_byHoangLong.xml`](functionList/Elvish_byHoangLong.xml) to the Function List parser configuration, then restart Notepad++.

Open [`UDL-samples/Elvish_byHoangLong.elv`](UDL-samples/Elvish_byHoangLong.elv) to see a small example.

## Repository layout

| Path | Purpose |
| --- | --- |
| `UDLs/` | Elvish syntax highlighting definition |
| `autoCompletion/` | Elvish autocompletion word list |
| `functionList/` | Function List parser definition |
| `UDL-samples/` | Example Elvish script |

## License

This project is licensed under the [MIT License](LICENSE).
