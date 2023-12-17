# pattern_patching

Pattern patching is a simple script **ppatch.sh** whose goal is to allow extending any kind of file, customizing any source code/file in order to adjust program/website/tool behavior by injecting/replacing text/code using a basic pattern system.

## How to get

Just download ppatch.sh file and use it as a shell script.

Easy download from main branch and add to bin folder :
> sudo curl --output /usr/bin/ppatch.sh -OL https://raw.githubusercontent.com/qremplak/pattern_patching/main/ppatch.sh && sudo chmod +x /usr/bin/ppatch.sh

## How to use

Just call shell script and specify a folder containing one or multiple patches to apply.

> ppatch.sh *<folder_containing_patches>*

Each patch is a simple file formatted as follow :

```html
<ACTION>
========================================
<TARGET_FILE_PATH>
========================================
<PATTERN>
========================================
<CONTENT>
```


| Name                      | Description                                     
| ------------------------- | ----------------------------------------------- 
| `ACTION`    | Customization action to apply                    
| `TARGET_FILE_PATH` | File on which apply customization 
| `PATTERN`     | Pattern to search 
| `CONTENT`     | Content to inject/replace at pattern occurence

List of available values for ACTION : 
- *inject_before* : inject CONTENT just before found PATTERN
- *inject_after* : inject CONTENT just after found PATTERN
- *replace* : replace PATTERN by CONTENT
- *replace_line* : replace whole line containing PATTERN by CONTENT

Each patch file has free name and can has any extension you prefer, in theory matching the target file you want to customize (in order to make syntax highlighting usable).

A simple example of patch file is given below.

```html
inject_after
========================================
example/ex_target_file.html
========================================
<body>
========================================
<div id="additional_panel" style='position:fixed; bottom:0px left:0px;'>
    <strong>Panel</strong>
</div>
```
In file *example/ex_target_file.html*, inject the provided content code just after the occurence of `<body>`.

You can apply multiple customizations on multiple files by preparing any number of patches files in the specified folder.

## Why ?

This small project is implemented primarily to address a personal need frequently encountered when building Docker images using existing technologies that require some adjustments. It will only be updated according to my future needs.

The advantages of this 'pattern-patching' approach are the following :
- Allow to make customizations reproductibles
- Avoid any manual modifications that breaks continuous building/deployment chain
- Pattern-based patching : not based on markers that are frequently variables like line numbers (ex. git diff)
- No need to create patch from diff calculation (ex. git diff) :
    - git diff : knowing A, **you design B**, and you let *git diff* build patch from A to B
    - ppatch : **you design patch** that generate B from A
- All customizations are described by simple patches files. This allows to maintain a logic of <i>patching as code</i>, making them more robust to versioning.
- Robust to special characters (ex. pattern containing sepecial characters)
- Potentially usable for any kind of scripts/codes for any language (.py, .c, .html, .css, .js, .php, .sh, etc.)
- Easily portable in any ubuntu context, notably usable in Dockerfile to allow on-the-fly customization during building

***/!\ ppatch command directly affects target files contents.*** 
Use it ideally in chains that build results from original files (making idempotent chains).

## Simple example

In the provided example we will patch a standard html file *example/target_file.html* :

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Page title</title>
  <link rel="stylesheet" href="style.css">
  <script src="script.js"></script>
</head>
<body>
    <h1>My First Heading</h1>
    <p>My first paragraph.</p>
</body>
</html>
```
... given the following result :

![Alt text](images/before.png)

There is a *example/patches* folder containing 4 patches :
- **inject_content_in_body.html** : inject html code at the beginning of body content
- **inject_head_script.html** : inject html code before the end of head content
- **replace_line_with_title** : replace whole line containing title by a custom content
- **replace_main_style** : replace the default style.css by a custom one

We can apply those patches with the following command : 
> bash ./ppatch.sh *example/patches*

We get the following altered code :

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Page title</title>
  <link rel="stylesheet" href="custom_style.css
">
  <script src="script.js"></script>

<script>

function printConsole(){
    console.log('Head script is working')
}
setInterval(checkURLchange, 1000);

</script>
</head>
<body>
<div id="additional_panel" style='
    padding:0.5rem;
    background-color:#EDF2F7DD;
    position:fixed; bottom:0px; left:0px;
    box-shadow: 0.25rem -0.25rem 0.5rem rgba(0, 50, 100, 0.10);
    border: 1px solid rgba(49, 53, 57, 0.4) !important;
'>
    <strong>Panel</strong>
</div>

<h2>New title</h2>
    <p>My first paragraph.</p>
</body>
</html>
```

... given the following result :

![Alt text](images/after.png)

## Quick usage in Dockerfile

```dockerfile
[...]

# Download ppatch
RUN curl --output /usr/bin/ppatch.sh -OL \
    https://raw.githubusercontent.com/qremplak/pattern_patching/main/ppatch.sh \
    && chmod +x /usr/bin/ppatch.sh
# Copy patches folder into container
COPY <folder_path> /home/<folder_path>
# Apply patches
RUN ppatch.sh /home/<folder_path>

[...]
```

## TODO
- Fix eventual anomalies
- Implement other patching actions (ex. delete)
- Implement more robust pattern detection alternatives (ex. regex based)
