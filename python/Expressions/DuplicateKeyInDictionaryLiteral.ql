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
 * @name Duplicate key in dict literal
 * @description Duplicate key in dict literal. All but the last will be lost.
 * @kind problem
 * @tags reliability
 *       useless-code
 *       external/cwe/cwe-561
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/duplicate-key-dict-literal
 */

import python
import semmle.python.strings

predicate dict_key(Dict d, Expr k, string s) {
    k = d.getAKey() and
    (
        s = ((Num)k).getN()
        or
        // We use � to mark unrepresentable characters
        // so two instances of � may represent different strings in the source code
        not "�" = s.charAt(_) and
        exists(StrConst c |
            c = k |
            s = "u\"" + c.getText() + "\"" and c.isUnicode()
            or
            s = "b\"" + c.getText() + "\"" and not c.isUnicode()
        )
    )
}

from Dict d, Expr k1, Expr k2
where exists(string s | dict_key(d, k1, s) and dict_key(d, k2, s) and k1 != k2) and
(
    exists(BasicBlock b, int i1, int i2 | 
        k1.getAFlowNode() = b.getNode(i1) and 
        k2.getAFlowNode() = b.getNode(i2) and 
        i1 < i2
    ) or
    k1.getAFlowNode().getBasicBlock().strictlyDominates(k2.getAFlowNode().getBasicBlock())
)
select k1, "Dictionary key " + repr(k1) + " is subsequently $@.", k2, "overwritten"
