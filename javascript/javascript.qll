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

/**
 * Provides classes for working with JavaScript programs, as well as JSON, YAML and HTML.
 */

import semmle.javascript.AMD
import semmle.javascript.AST
import semmle.javascript.BasicBlocks
import semmle.javascript.CFG
import semmle.javascript.Classes
import semmle.javascript.Comments
import semmle.javascript.Concepts
import semmle.javascript.Constants
import semmle.javascript.DataFlow
import semmle.javascript.DefUse
import semmle.javascript.DOM
import semmle.javascript.Errors
import semmle.javascript.ES2015Modules
import semmle.javascript.Expr
import semmle.javascript.Externs
import semmle.javascript.Files
import semmle.javascript.Functions
import semmle.javascript.HTML
import semmle.javascript.JSDoc
import semmle.javascript.JSON
import semmle.javascript.JSX
import semmle.javascript.Lines
import semmle.javascript.Locations
import semmle.javascript.Modules
import semmle.javascript.NodeJS
import semmle.javascript.NPM
import semmle.javascript.Paths
import semmle.javascript.CanonicalNames
import semmle.javascript.Regexp
import semmle.javascript.SSA
import semmle.javascript.StandardLibrary
import semmle.javascript.Stmt
import semmle.javascript.Templates
import semmle.javascript.Tokens
import semmle.javascript.TypeScript
import semmle.javascript.Util
import semmle.javascript.Variables
import semmle.javascript.XML
import semmle.javascript.YAML
import semmle.javascript.dataflow.CallGraph
import semmle.javascript.dataflow.DataFlow
import semmle.javascript.dataflow.TaintTracking
import semmle.javascript.dataflow.TypeInference
import semmle.javascript.frameworks.AngularJS
import semmle.javascript.frameworks.AWS
import semmle.javascript.frameworks.Azure
import semmle.javascript.frameworks.Babel
import semmle.javascript.frameworks.Credentials
import semmle.javascript.frameworks.CryptoLibraries
import semmle.javascript.frameworks.DigitalOcean
import semmle.javascript.frameworks.Electron
import semmle.javascript.frameworks.jQuery
import semmle.javascript.frameworks.LodashUnderscore
import semmle.javascript.frameworks.HttpFrameworks
import semmle.javascript.frameworks.NoSQL
import semmle.javascript.frameworks.PkgCloud
import semmle.javascript.frameworks.React
import semmle.javascript.frameworks.Request
import semmle.javascript.frameworks.SQL
import semmle.javascript.frameworks.UriLibraries
import semmle.javascript.frameworks.XmlParsers
import semmle.javascript.frameworks.xUnit
import semmle.javascript.linters.ESLint
import semmle.javascript.linters.JSLint
import semmle.javascript.linters.Linting
import semmle.javascript.security.dataflow.RemoteFlowSources
