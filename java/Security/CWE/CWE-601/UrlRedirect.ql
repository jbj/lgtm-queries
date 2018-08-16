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
 * @name URL redirection from remote source
 * @description URL redirection based on unvalidated user-input
 *              may cause redirection to malicious web sites.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id java/unvalidated-url-redirection
 * @tags security
 *       external/cwe/cwe-601
 */
import java
import semmle.code.java.dataflow.FlowSources
import UrlRedirect

class UrlRedirectConfig extends TaintTracking::Configuration {
  UrlRedirectConfig() { this = "UrlRedirectConfig" }
  override predicate isSource(DataFlow::Node source) { source instanceof RemoteUserInput }
  override predicate isSink(DataFlow::Node sink) { sink instanceof UrlRedirectSink }
}

from UrlRedirectSink sink, RemoteUserInput source, UrlRedirectConfig conf
where conf.hasFlow(source, sink)
select sink, "Potentially untrusted URL redirection due to $@.",
  source, "user-provided value"
