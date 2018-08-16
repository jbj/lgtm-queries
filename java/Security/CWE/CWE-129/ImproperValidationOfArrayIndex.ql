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
 * @name Improper validation of user-provided array index
 * @description Using external input as an index to an array, without proper validation, can lead to index out of bound exceptions.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @id java/improper-validation-of-array-index
 * @tags security
 *       external/cwe/cwe-129
 */

import java
import ArraySizing
import semmle.code.java.dataflow.FlowSources

class Conf extends TaintTracking::Configuration {
  Conf() { this = "RemoteUserInputTocanThrowOutOfBoundsDueToEmptyArrayConfig" }
  override predicate isSource(DataFlow::Node source) { source instanceof RemoteUserInput }
  override predicate isSink(DataFlow::Node sink) {
    any(CheckableArrayAccess caa).canThrowOutOfBounds(sink.asExpr())
  }
  override predicate isSanitizer(DataFlow::Node node) { node.getType() instanceof BooleanType }
}

from RemoteUserInput source, Expr index, CheckableArrayAccess arrayAccess
where
  arrayAccess.canThrowOutOfBounds(index) and
  any(Conf conf).hasFlow(source, DataFlow::exprNode(index))
select arrayAccess.getIndexExpr(),
  "$@ flows to here and is used as an index causing an ArrayIndexOutOfBoundsException.",
  source, "User-provided value"
