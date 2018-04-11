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
 * Provides a taint-tracking configuration for reasoning about unvalidated URL
 * redirection problems on the server side.
 */

import javascript
import RemoteFlowSources
import UrlConcatenation

/**
 * A data flow source for unvalidated URL redirect vulnerabilities.
 */
abstract class ServerSideUrlRedirectSource extends DataFlow::Node { }

/**
 * A data flow sink for unvalidated URL redirect vulnerabilities.
 */
abstract class ServerSideUrlRedirectSink extends DataFlow::Node {
  /**
   * Holds if this sink may redirect to a non-local URL.
   */
  predicate maybeNonLocal() {
    exists (Expr prefix | prefix = getAPrefix(this) |
      not exists(prefix.getStringValue())
      or
      exists (string prefixVal | prefixVal = prefix.getStringValue() |
        // local URLs (i.e., URLs that start with `/` not followed by `\` or `/`,
        // or that start with `~/`) are unproblematic
        not prefixVal.regexpMatch("/[^\\\\/].*|~/.*") and
        // so are localhost URLs
        not prefixVal.regexpMatch("(\\w+:)?//localhost[:/].*")
      )
    )
  }
}

/**
 * Gets an expression that may end up being a prefix of the string
 * concatenation `nd`.
 */
private Expr getAPrefix(DataFlow::Node nd) {
  if exists(nd.getAPredecessor()) then
    result = getAPrefix(nd.getAPredecessor())
  else exists (Expr e | e = nd.asExpr() |
    if (e instanceof AddExpr or e instanceof AssignAddExpr) then
      result = getAPrefix(DataFlow::valueNode(e.getChildExpr(0)))
    else
      result = e
  )
}

/**
 * A sanitizer for unvalidated URL redirect vulnerabilities.
 */
abstract class ServerSideUrlRedirectSanitizer extends DataFlow::Node { }

/**
 * A taint-tracking configuration for reasoning about unvalidated URL redirections.
 */
class ServerSideUrlRedirectDataFlowConfiguration extends TaintTracking::Configuration {
  ServerSideUrlRedirectDataFlowConfiguration() { this = "ServerSideUrlRedirectDataFlowConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof ServerSideUrlRedirectSource or
    source instanceof RemoteFlowSource
  }

  override predicate isSink(DataFlow::Node sink) {
    sink.(ServerSideUrlRedirectSink).maybeNonLocal()
  }

  override predicate isSanitizer(DataFlow::Node node) {
    super.isSanitizer(node) or
    node instanceof ServerSideUrlRedirectSanitizer
  }

  override predicate isSanitizer(DataFlow::Node source, DataFlow::Node sink) {
    sanitizingPrefixEdge(source, sink)
  }
}

/**
 * An HTTP redirect, considered as a sink for `ServerSideUrlRedirectDataFlowConfiguration`.
 */
class RedirectSink extends ServerSideUrlRedirectSink, DataFlow::ValueNode {
  RedirectSink() {
    astNode = any(HTTP::RedirectInvocation redir).getUrlArgument()
  }
}

/**
 * A definition of the HTTP "Location" header, considered as a sink for
 * `ServerSideUrlRedirectDataFlowConfiguration`.
 */
class LocationHeaderSink extends ServerSideUrlRedirectSink, DataFlow::ValueNode {
  LocationHeaderSink() {
    any(HTTP::ExplicitHeaderDefinition def).definesExplicitly("Location", astNode)
  }
}

/**
 * A call to a function called `isLocalUrl` or similar, which is
 * considered to sanitize a variable for purposes of URL redirection.
 */
class LocalUrlSanitizingGuard extends TaintTracking::SanitizingGuard, CallExpr {
  LocalUrlSanitizingGuard() {
    this.getCalleeName().regexpMatch("(?i)(is_?)?local_?url")
  }

  override predicate sanitizes(TaintTracking::Configuration cfg, boolean outcome, Expr e) {
    cfg instanceof ServerSideUrlRedirectDataFlowConfiguration and
    // `isLocalUrl(e)` sanitizes `e` if it evaluates to `true`
    this.getAnArgument() = e and
    outcome = true
  }
}
