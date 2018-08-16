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
 * @name HTTP response splitting
 * @description Writing user input directly to an HTTP header
 *              makes code vulnerable to attack by header splitting.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id java/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 */
import java
import ResponseSplitting

class ResponseSplittingConfig extends TaintTracking::Configuration {
  ResponseSplittingConfig() { this = "ResponseSplittingConfig" }
  override predicate isSource(DataFlow::Node source) {
    source instanceof RemoteUserInput and
    not source instanceof WhitelistedSource
  }
  override predicate isSink(DataFlow::Node sink) { sink instanceof HeaderSplittingSink }
}

from HeaderSplittingSink sink, RemoteUserInput source, ResponseSplittingConfig conf
where conf.hasFlow(source, sink)
select sink, "Response-splitting vulnerability due to this $@.",
  source, "user-provided value"
