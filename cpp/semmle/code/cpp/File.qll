// Copyright 2018 Semmle Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.

import semmle.code.cpp.Element
import semmle.code.cpp.Declaration
import semmle.code.cpp.metrics.MetricFile

/** A file or folder. */
abstract class Container extends @container {
  /**
   * Gets the absolute, canonical path of this container, using forward slashes
   * as path separator.
   *
   * The path starts with a _root prefix_ followed by zero or more _path
   * segments_ separated by forward slashes.
   *
   * The root prefix is of one of the following forms:
   *
   *   1. A single forward slash `/` (Unix-style)
   *   2. An upper-case drive letter followed by a colon and a forward slash,
   *      such as `C:/` (Windows-style)
   *   3. Two forward slashes, a computer name, and then another forward slash,
   *      such as `//FileServer/` (UNC-style)
   *
   * Path segments are never empty (that is, absolute paths never contain two
   * contiguous slashes, except as part of a UNC-style root prefix). Also, path
   * segments never contain forward slashes, and no path segment is of the
   * form `.` (one dot) or `..` (two dots).
   *
   * Note that an absolute path never ends with a forward slash, except if it is
   * a bare root prefix, that is, the path has no path segments. A container
   * whose absolute path has no segments is always a `Folder`, not a `File`.
   */
  abstract string getAbsolutePath();

  /**
   * Gets a URL representing the location of this container.
   *
   * For more information see https://lgtm.com/help/ql/locations#providing-urls.
   */
  abstract string getURL();

  /**
   * Gets the relative path of this file or folder from the root folder of the
   * analyzed source location. The relative path of the root folder itself is
   * the empty string.
   *
   * This has no result if the container is outside the source root, that is,
   * if the root folder is not a reflexive, transitive parent of this container.
   */
  string getRelativePath() {
    exists (string absPath, string pref |
      absPath = getAbsolutePath() and sourceLocationPrefix(pref) |
      absPath = pref and result = ""
      or
      absPath = pref.regexpReplaceAll("/$", "") + "/" + result and
      not result.matches("/%")
    )
  }

  /**
   * Gets the base name of this container including extension, that is, the last
   * segment of its absolute path, or the empty string if it has no segments.
   *
   * Here are some examples of absolute paths and the corresponding base names
   * (surrounded with quotes to avoid ambiguity):
   *
   * <table border="1">
   * <tr><th>Absolute path</th><th>Base name</th></tr>
   * <tr><td>"/tmp/tst.js"</td><td>"tst.js"</td></tr>
   * <tr><td>"C:/Program Files (x86)"</td><td>"Program Files (x86)"</td></tr>
   * <tr><td>"/"</td><td>""</td></tr>
   * <tr><td>"C:/"</td><td>""</td></tr>
   * <tr><td>"D:/"</td><td>""</td></tr>
   * <tr><td>"//FileServer/"</td><td>""</td></tr>
   * </table>
   */
  string getBaseName() {
    result = getAbsolutePath().regexpCapture(".*/(([^/]*?)(?:\\.([^.]*))?)", 1)
  }

  /**
   * Gets the extension of this container, that is, the suffix of its base name
   * after the last dot character, if any.
   *
   * In particular,
   *
   *  - if the name does not include a dot, there is no extension, so this
   *    predicate has no result;
   *  - if the name ends in a dot, the extension is the empty string;
   *  - if the name contains multiple dots, the extension follows the last dot.
   *
   * Here are some examples of absolute paths and the corresponding extensions
   * (surrounded with quotes to avoid ambiguity):
   *
   * <table border="1">
   * <tr><th>Absolute path</th><th>Extension</th></tr>
   * <tr><td>"/tmp/tst.js"</td><td>"js"</td></tr>
   * <tr><td>"/tmp/.classpath"</td><td>"classpath"</td></tr>
   * <tr><td>"/bin/bash"</td><td>not defined</td></tr>
   * <tr><td>"/tmp/tst2."</td><td>""</td></tr>
   * <tr><td>"/tmp/x.tar.gz"</td><td>"gz"</td></tr>
   * </table>
   */
  string getExtension() {
    result = getAbsolutePath().regexpCapture(".*/([^/]*?)(\\.([^.]*))?", 3)
  }

  /**
   * Gets the stem of this container, that is, the prefix of its base name up to
   * (but not including) the last dot character if there is one, or the entire
   * base name if there is not.
   *
   * Here are some examples of absolute paths and the corresponding stems
   * (surrounded with quotes to avoid ambiguity):
   *
   * <table border="1">
   * <tr><th>Absolute path</th><th>Stem</th></tr>
   * <tr><td>"/tmp/tst.js"</td><td>"tst"</td></tr>
   * <tr><td>"/tmp/.classpath"</td><td>""</td></tr>
   * <tr><td>"/bin/bash"</td><td>"bash"</td></tr>
   * <tr><td>"/tmp/tst2."</td><td>"tst2"</td></tr>
   * <tr><td>"/tmp/x.tar.gz"</td><td>"x.tar"</td></tr>
   * </table>
   */
  string getStem() {
    result = getAbsolutePath().regexpCapture(".*/([^/]*?)(?:\\.([^.]*))?", 1)
  }

  /** Gets the parent container of this file or folder, if any. */
  Container getParentContainer() {
    containerparent(result, this)
  }

  /** Gets a file or sub-folder in this container. */
  Container getAChildContainer() {
    this = result.getParentContainer()
  }

  /** Gets a file in this container. */
  File getAFile() {
    result = getAChildContainer()
  }

  /** Gets the file in this container that has the given `baseName`, if any. */
  File getFile(string baseName) {
    result = getAFile() and
    result.getBaseName() = baseName
  }

  /** Gets a sub-folder in this container. */
  Folder getAFolder() {
    result = getAChildContainer()
  }

  /** Gets the sub-folder in this container that has the given `baseName`, if any. */
  Folder getFolder(string baseName) {
    result = getAFolder() and
    result.getBaseName() = baseName
  }

  /**
   * Gets a textual representation of the path of this container.
   *
   * This is the absolute path of the container.
   */
  string toString() {
    result = getAbsolutePath()
  }
}

/**
 * A folder that was observed on disk during the build process.
 *
 * For the example folder name of "/usr/home/me", the path decomposes to:
 *
 *  1. "/usr/home" - see `getParentContainer`.
 *  2. "me" - see `getBaseName`.
 *
 * To get the full path, use `getAbsolutePath`.
 */
class Folder extends Container, @folder {
  override string getAbsolutePath() {
    folders(this, result, _)
  }

  /** Gets the URL of this folder. */
  string getURL() {
    result = "folder://" + getAbsolutePath()
  }

  /**
   * DEPRECATED: use `getAbsolutePath` instead.
   * Gets the name of this folder.
   */
  deprecated
  string getName() { folders(this,result,_) }

  /**
   * DEPRECATED: use `getAbsolutePath` instead.
   * Holds if this element is named `name`.
   */
  deprecated
  predicate hasName(string name) { name = this.getName() }

  /**
   * DEPRECATED: use `getAbsolutePath` instead.
   * Gets the full name of this folder.
   */
  deprecated
  string getFullName() { result = this.getName() }

  /**
   * DEPRECATED: use `getBaseName` instead.
   * Gets the last part of the folder name.
   */
  deprecated
  string getShortName() {
    exists (string longnameRaw, string longname
    | folders(this,_,longnameRaw) and
      longname = longnameRaw.replaceAll("\\", "/")
    | exists (int index
      | result = longname.splitAt("/", index) and
        not exists (longname.splitAt("/", index+1))))
  }

  /**
   * DEPRECATED: use `getParentContainer` instead.
   * Gets the parent folder.
   */
  deprecated
  Folder getParent() { containerparent(result,this) }
}

/**
 * A file that was observed on disk during the build process.
 *
 * For the example filename of "/usr/home/me/myprogram.c", the filename
 * decomposes to:
 *
 *  1. "/usr/home/me" - see `getParentContainer`.
 *  2. "myprogram.c" - see `getBaseName`.
 *
 * The base name further decomposes into the _stem_ and _extension_ -- see
 * `getStem` and `getExtension`. To get the full path, use `getAbsolutePath`.
 */
class File extends Container, @file, Locatable {
  override string getAbsolutePath() {
    files(this, result, _, _, _)
  }

  override string toString() {
    result = Container.super.toString()
  }

  /** Gets the URL of this file. */
  string getURL() {
    result = "file://" + this.getAbsolutePath() + ":0:0:0:0"
  }

  /** Holds if this file was compiled as C (at any point). */
  predicate compiledAsC() {
    fileannotations(this,1,"compiled as c","1")
  }

  /** Holds if this file was compiled as C++ (at any point). */
  predicate compiledAsCpp() {
    fileannotations(this,1,"compiled as c++","1")
  }

  /** Holds if this file was compiled as Objective C (at any point). */
  predicate compiledAsObjC() {
    fileannotations(this,1,"compiled as obj c","1")
  }

  /** Holds if this file was compiled as Objective C++ (at any point). */
  predicate compiledAsObjCpp() {
    fileannotations(this,1,"compiled as obj c++","1")
  }

  /** Holds if this file was compiled by a Microsoft compiler (at any point). */
  predicate compiledAsMicrosoft() {
    exists(Compilation c |
      c.getAFileCompiled() = this and
      c.getAnArgument() = "--microsoft"
    )
  }

  /** Gets a top-level element declared in this file. */
  Declaration getATopLevelDeclaration() {
    result.getAFile() = this and result.isTopLevel()
  }

  /** Gets a declaration in this file. */
  Declaration getADeclaration() { result.getAFile() = this }

  /** Holds if this file uses the given macro. */
  predicate usesMacro(Macro m) {
    exists(MacroInvocation mi | mi.getFile() = this and
                                mi.getMacro() = m)
  }

  /**
   * Gets a file that is directly included from this file (using a
   * pre-processor directive like `#include`).
   */
  File getAnIncludedFile() {
    exists(Include i | i.getFile() = this and i.getIncludedFile() = result)
  }

  /**
   * DEPRECATED: use `getParentContainer` instead.
   * Gets the folder which contains this file.
   */
  deprecated
  Folder getParent() { containerparent(result,this) }

  /**
   * Holds if this file may be from source. This predicate holds for all files
   * except the dummy file, whose name is the empty string, which contains
   * declarations that are built into the compiler.
   */
  predicate fromSource() { numlines(this,_,_,_) }

  /**
   * Holds if this file may be from a library.
   *
   * DEPRECATED: For historical reasons this is true for any file.
   */
  deprecated
  predicate fromLibrary() { any() }

  /** Gets the metric file. */
  MetricFile getMetrics() { result = this }

  /**
   * DEPRECATED: Use `getAbsolutePath` instead.
   * Gets the full name of this file, for example:
   * "/usr/home/me/myprogram.c".
   */
  deprecated
  string getName() { files(this,result,_,_,_) }

  /**
   * DEPRECATED: Use `getAbsolutePath` instead.
   * Holds if this file has the specified full name.
   *
   * Example usage: `f.hasName("/usr/home/me/myprogram.c")`.
   */
  deprecated
  predicate hasName(string name) { name = this.getName() }

  /**
   * DEPRECATED: Use `getAbsolutePath` instead.
   * Gets the full name of this file, for example
   * "/usr/home/me/myprogram.c".
   */
  deprecated
  string getFullName() { result = this.getName() }

  /**
   * Gets the remainder of the base name after the first dot character. Note
   * that the name of this predicate is in plural form, unlike `getExtension`,
   * which gets the remainder of the base name after the _last_ dot character.
   *
   * Predicates `getStem` and `getExtension` should be preferred over
   * `getShortName` and `getExtensions` since the former pair is compatible
   * with the file libraries of other languages.
   * Note the slight difference between this predicate and `getStem`:
   * for example, for "file.tar.gz", this predicate will have the result
   * "tar.gz", while `getExtension` will have the result "gz".
   */
  string getExtensions() {
    files(this,_,_,result,_)
  }

  /**
   * DEPRECATED: Use `getBaseName` instead.
   * Gets the name and extension(s), but not path, of a file. For example,
   * if the full name is "/path/to/filename.a.bcd" then the filename is
   * "filename.a.bcd".
   */
  deprecated
  string getFileName() {
      // [a/b.c/d/]fileName
      //         ^ beginAfter
      exists(string fullName, int beginAfter |
          fullName = this.getName() and
          beginAfter = max(int i | i = -1 or fullName.charAt(i) = "/" | i) and
          result = fullName.suffix(beginAfter + 1)
      )
  }

  /**
   * Gets the short name of this file, that is, the prefix of its base name up
   * to (but not including) the first dot character if there is one, or the
   * entire base name if there is not. For example, if the full name is
   * "/path/to/filename.a.bcd" then the short name is "filename".
   *
   * Predicates `getStem` and `getExtension` should be preferred over
   * `getShortName` and `getExtensions` since the former pair is compatible
   * with the file libraries of other languages.
   * Note the slight difference between this predicate and `getStem`:
   * for example, for "file.tar.gz", this predicate will have the result
   * "file", while `getStem` will have the result "file.tar".
   */
  string getShortName() { files(this,_,result,_,_) }
}


/**
 * A C/C++ header file, as determined (mainly) by file extension.
 *
 * For the related notion of whether a file is included anywhere (using a
 * pre-processor directive like `#include`), use `Include.getIncludedFile`.
 */
class HeaderFile extends File {

  HeaderFile() {
    exists(string ext | ext = this.getExtension().toLowerCase() |
      ext = "h" or ext = "r"
      /*    ---   */ or ext = "hpp" or ext = "hxx" or ext = "h++" or ext = "hh" or ext = "hp"
      or ext = "tcc" or ext = "tpp" or ext = "txx" or ext = "t++" /*    ---         ---    */
    )
    or
    not exists(this.getExtension()) and
    exists(Include i | i.getIncludedFile() = this)
  }

}

/**
 * A C source file, as determined by file extension.
 *
 * For the related notion of whether a file is compiled as C code, use
 * `File.compiledAsC`.
 */
class CFile extends File {

  CFile() {
    exists(string ext | ext = this.getExtension().toLowerCase() |
      ext = "c" or ext = "i"
    )
  }

}

/**
 * A C++ source file, as determined by file extension.
 *
 * For the related notion of whether a file is compiled as C++ code, use
 * `File.compiledAsCpp`.
 */
class CppFile extends File {

  CppFile() {
    exists(string ext | ext = this.getExtension().toLowerCase() |
      /*     ---     */ ext = "cpp" or ext = "cxx" or ext = "c++" or ext = "cc" or ext = "cp"
      or ext = "icc" or ext = "ipp" or ext = "ixx" or ext = "i++" or ext = "ii" /*  ---    */
      // Note: .C files are indistinguishable from .c files on some
      // file systems, so we just treat them as CFile's.
    )
  }

}

/**
 * An Objective C source file, as determined by file extension.
 *
 * For the related notion of whether a file is compiled as Objective C
 * code, use `File.compiledAsObjC`.
 */
class ObjCFile extends File {

  ObjCFile() {
    exists(string ext | ext = this.getExtension().toLowerCase() |
      ext = "m" or ext = "mi"
    )
  }

}

/**
 * An Objective C++ source file, as determined by file extension.
 *
 * For the related notion of whether a file is compiled as Objective C++
 * code, use `File.compiledAsObjCpp`.
 */
class ObjCppFile extends File {

  ObjCppFile() {
    exists(string ext | ext = this.getExtension().toLowerCase() |
      ext = "mm" or ext = "mii"
      // Note: .M files are indistinguishable from .m files on some
      // file systems, so we just treat them as ObjCFile's.
    )
  }

}
