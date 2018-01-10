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
 * @name Disabling SCE
 * @description Disabling strict contextual escaping (SCE) can cause security vulnerabilities.
 * @kind problem
 * @problem.severity warning
 * @precision very-high
 * @id js/angular/disabling-sce
 * @tags security
 *       maintainability
 *       frameworks/angularjs
 */

import javascript

from MethodCallExpr mce, AngularJS::BuiltinServiceReference service
where service.getName() ="$sceProvider" and
      mce = service.getAMethodCall( "enabled") and
      mce.getArgument(0).(DataFlowNode).getALocalSource().(BooleanLiteral).getValue() = "false"
select mce, "Disabling SCE is strongly discouraged."
