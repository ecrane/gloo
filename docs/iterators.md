# Iterators

**Contents**

- Each
- Each Child
- Each Directory
- Each File
- Each Line
- Each Word
- Repeat

## Each

Perform an action for each item in a collection.

There are several variations on this object type. They are:

- each child object in a container
- each directory in a folder
- each file in a folder
- each line in a block of text (string)
- each word in a string

The general pattern is that there are three children:

- An `in` object that points to the item collection.
- A reference to the item instance. This reference is updated each time through the loop. Note that the name of this child is used to determine which kind of loop is in play.
- A `do` script to run for each iteration through the loop.

Messages:

- `run` — Run the loop for each item in the collection.

See examples in the specific variations, below.

See also: Object Base.

## Each Child

Iterate for each child in a container.

Children:

- `child` (alias)
    - Alias to the child instance.
- `in` (container)
    - The collection of objects we will iterate over.
- `do` (script)
    - The action we want to perform for each child in the container.

### Group By

Group the results by a child property. This is an optional feature. It can be used when we want to do something specific every time a value in the child object changes.

Whenever the `group_by` value changes, the `on_group_start` and `on_group_end` scripts are run. This can be used to aggregate results in rows or other groupings.

The group by feature adds the following children:

- `group_by` (string)
    - The name of the child object we want to group by. This will be a property of the object instance of the `child` container.
- `on_group_start` (script)
    - The action we want to perform when the `group_by` value changes. This script will be run before the `do` script for the first instance of the child with the new `group_by` value.
- `on_group_end` (script)
    - The action we want to perform when the `group_by` value changes. This script will be run after the `do` script for the last instance of the `group_by` value.

Messages:

- `run` — Run the loop for each object in the container.

```gloo
#
# Show each child in a container.
#
each_child [can] :

# Iterator on children of a container.
  for [each] :
    child [alias] :
    in [alias] : each_child.objs
    do [script] : show ^.child

  # Data
  objs [can] :
    1 [string] : one
    2 [string] : two
    3 [string] : three

  # Run the iterator.
  on_load [script] :
    show 'showing children in container' (white)
    tell each_child.for to run
```

See also: Object Base, Each, Each File, Each Line, Each Word.

## Each Directory

Iterate for each directory in a folder (directory).

Children:

- `dir` (file — a directory)
    - The directory instance.
- `in` (file — a directory)
    - The folder (directory) we will look in for directories.
- `do` (script)
    - The action we want to perform for each directory in the folder.

Messages:

- `run` — Run the loop for each directory.

```gloo
#
# Show each directory.
#
each_dir [can] :

  # Iterator on files in a folder.
  for [each] :
    dir [file] :
    in [file] : /my/folder/
    do [script] : show ^.dir

  # Run the iterator.
  on_load [script] :
    show 'showing directory' (white)
    tell each_dir.for to run
```

See also: Each, Each File.

## Each File

Iterate for each file in a folder (directory).

Children:

- `file` (file)
    - The file instance.
- `in` (file)
    - The folder (directory) we will look in for files.
- `do` (script)
    - The action we want to perform for each file in the folder.
- `ext` (string)
    - Optional file extension. Limit to files of this kind.

Messages:

- `run` — Run the loop for each file in the folder.

```gloo
#
# Show each file in a folder.
#
each_file [can] :

  # Iterator on files in a folder.
  for [each] :
    file [file] :
    ext [string] : gloo
    in [file] : /my/folder/
    do [script] : show ^.file

  # Run the iterator.
  on_load [script] :
    show 'showing files in folder' (white)
    tell each_file.for to run
```

See also: Object Base, Each, Each Line, Each Word, Each Child, Each Directory.

## Each Line

Iterate for each line in a text block (string).

Children:

- `line` (string)
    - The single line of text.
- `in` (text)
    - The block of text or string.
- `do` (script)
    - The action we want to perform for each line in the text.

Messages:

- `run` — Run the loop for each line in the text.

```gloo
#
# Show each line in a string.
#
each_line [can] :

  # Iterator on children of a container.
  for [each] :
    line [string] :
    in [alias] : ^.in
    do [script] : show ^.line

  # Data
  in [txt] : BEGIN
    I will now write a poem
    of several lines
    Then I will show it
    and it will be awesome!
    END

  # Run the iterator.
  on_load [script] :
    show 'showing lines in a text block' (white)
    tell each_line.for to run
```

See also: Object Base, Each, Each Word, Each Child, Each File.

## Each Word

Iterate for each word in a string.

Children:

- `word` (string)
    - The word (string).
- `in` (string)
    - The source string.
- `do` (script)
    - The action we want to perform for each word in the string.

Messages:

- `run` — Run the loop for each word in the string.

```gloo
#
# Show each word in a string.
#
each_word [can] :

  # Iterator on words in a string.
  for [each] :
    word [string] :
    in [string] : one word at a time
    do [script] : show ^.word

  # Run the iterator.
  on_load [script] :
    show 'showing words in a string' (white)
    tell each_word.for to run
```

See also: Object Base, Each, Each Child, Each File, Each Line.

## Repeat

Run a script a given number of times.

Children:

- `times` (integer)
    - Default: `0`
    - The number of times to run the script.
- `index` (integer)
    - Default: `0`
    - The current iteration when the repeat loop is running.
- `do` (script)
    - The action we want to perform for iteration of the loop.

Messages:

- `run` — Run the script for the given number of times.

```gloo
repeat [can] :
  s [string] :
  on_load [script] :
    put $.screen_cols / 2 into repeat.x.times
    tell repeat.x to run
    show repeat.s
    tell repeat.y to run
    show repeat.s
  x [repeat] :
    times [integer] : 30
    index [integer] : 0
    do [script] : put repeat.s + '-' into repeat.s
  y [repeat] :
    times [integer] : 10
    index [integer] : 0
    do [script] : show repeat.y.index
```

See also: Object Base.
