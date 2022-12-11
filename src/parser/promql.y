// Copyright 2019 The Prometheus Authors
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Copyright 2022 Greptime Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

%token EQL
BLANK
COLON
COMMA
COMMENT
DURATION
EOF
ERROR
IDENTIFIER
LEFT_BRACE
LEFT_BRACKET
LEFT_PAREN
METRIC_IDENTIFIER
NUMBER
RIGHT_BRACE
RIGHT_BRACKET
RIGHT_PAREN
SEMICOLON
SPACE
STRING
TIMES

// Operators.
%token OPERATORS_START
ADD
DIV
EQLC
EQL_REGEX
GTE
GTR
LAND
LOR
LSS
LTE
LUNLESS
MOD
MUL
NEQ
NEQ_REGEX
POW
SUB
AT
ATAN2
%token OPERATORS_END

// Aggregators.
%token AGGREGATORS_START
AVG
BOTTOMK
COUNT
COUNT_VALUES
GROUP
MAX
MIN
QUANTILE
STDDEV
STDVAR
SUM
TOPK
%token AGGREGATORS_END

// Keywords.
%token KEYWORDS_START
BOOL
BY
GROUP_LEFT
GROUP_RIGHT
IGNORING
OFFSET
ON
WITHOUT
%token KEYWORDS_END

// Preprocessors.
%token PREPROCESSOR_START
START
END
%token PREPROCESSOR_END

// Start symbols for the generated parser.
%token STARTSYMBOLS_START
START_METRIC
START_SERIES_DESCRIPTION
START_EXPRESSION
START_METRIC_SELECTOR
%token STARTSYMBOLS_END

%start start

// Operators are listed with increasing precedence.
%left LOR
%left LAND LUNLESS
%left EQLC GTE GTR LSS LTE NEQ
%left ADD SUB
%left MUL DIV MOD ATAN2
%right POW

// Offset modifiers do not have associativity.
%nonassoc OFFSET

// This ensures that it is always attempted to parse range or subquery selectors when a left
// bracket is encountered.
%right LEFT_BRACKET

%%


/* start           : */
/*                 START_METRIC metric */
/*                         /\* { yylex.(*parser).generatedParserResult = $2 } *\/ */
/*                 | START_SERIES_DESCRIPTION series_description */
/*                 | START_EXPRESSION /\* empty *\/ EOF */
/*                         /\* { yylex.(*parser).addParseErrf(PositionRange{}, "no expression found in input")} *\/ */
/*                 | START_EXPRESSION expr */
/*                         /\* { yylex.(*parser).generatedParserResult = $2 } *\/ */
/*                 | START_METRIC_SELECTOR vector_selector */
/*                         /\* { yylex.(*parser).generatedParserResult = $2 } *\/ */
/*                 | start EOF */
/*                 | error /\* If none of the more detailed error messages are triggered, we fall back to this. *\/ */
/*                         /\* { yylex.(*parser).unexpected("","") } *\/ */
/*                 ; */

/* expr            : */
/*                 aggregate_expr */
/*                 | binary_expr */
/*                 | function_call */
/*                 | matrix_selector */
/*                 | number_literal */
/*                 | offset_expr */
/*                 | paren_expr */
/*                 | string_literal */
/*                 | subquery_expr */
/*                 | unary_expr */
/*                 | vector_selector */
/*                 | step_invariant_expr */
/*                 ; */

/* /\* */
/*  * Aggregations. */
/*  *\/ */

/* aggregate_expr  : aggregate_op aggregate_modifier function_call_body */
/*                         /\* { $$ = yylex.(*parser).newAggregateExpr($1, $2, $3) } *\/ */
/*                 | aggregate_op function_call_body aggregate_modifier */
/*                         /\* { $$ = yylex.(*parser).newAggregateExpr($1, $3, $2) } *\/ */
/*                 | aggregate_op function_call_body */
/*                         /\* { $$ = yylex.(*parser).newAggregateExpr($1, &AggregateExpr{}, $2) } *\/ */
/*                 | aggregate_op error */
/*                         /\* { *\/ */
/*                         /\* yylex.(*parser).unexpected("aggregation",""); *\/ */
/*                         /\* $$ = yylex.(*parser).newAggregateExpr($1, &AggregateExpr{}, Expressions{}) *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* aggregate_modifier: */
/*                 BY grouping_labels */
/*                         /\* { *\/ */
/*                         /\* $$ = &AggregateExpr{ *\/ */
/*                         /\*         Grouping: $2, *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 | WITHOUT grouping_labels */
/*                         /\* { *\/ */
/*                         /\* $$ = &AggregateExpr{ *\/ */
/*                         /\*         Grouping: $2, *\/ */
/*                         /\*         Without:  true, *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* /\* */
/*  * Binary expressions. */
/*  *\/ */

/* // Operator precedence only works if each of those is listed separately. */
/* binary_expr     : expr ADD     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr ATAN2   bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr DIV     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr EQLC    bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr GTE     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr GTR     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr LAND    bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr LOR     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr LSS     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr LTE     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr LUNLESS bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr MOD     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr MUL     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr NEQ     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr POW     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 | expr SUB     bin_modifier expr /\* { $$ = yylex.(*parser).newBinaryExpression($1, $2, $3, $4) } *\/ */
/*                 ; */

/* // Using left recursion for the modifier rules, helps to keep the parser stack small and */
/* // reduces allocations */
/* bin_modifier    : group_modifiers; */

/* bool_modifier   : /\* empty *\/ */
/*                         /\* { $$ = &BinaryExpr{ *\/ */
/*                         /\* VectorMatching: &VectorMatching{Card: CardOneToOne}, *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 | BOOL */
/*                         /\* { $$ = &BinaryExpr{ *\/ */
/*                         /\* VectorMatching: &VectorMatching{Card: CardOneToOne}, *\/ */
/*                         /\* ReturnBool:     true, *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* on_or_ignoring  : bool_modifier IGNORING grouping_labels */
/*                         /\* { *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* $$.(*BinaryExpr).VectorMatching.MatchingLabels = $3 *\/ */
/*                         /\* } *\/ */
/*                 | bool_modifier ON grouping_labels */
/*                         /\* { *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* $$.(*BinaryExpr).VectorMatching.MatchingLabels = $3 *\/ */
/*                         /\* $$.(*BinaryExpr).VectorMatching.On = true *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* group_modifiers: bool_modifier /\* empty *\/ */
/*                 | on_or_ignoring /\* empty *\/ */
/*                 | on_or_ignoring GROUP_LEFT maybe_grouping_labels */
/*                         /\* { *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* $$.(*BinaryExpr).VectorMatching.Card = CardManyToOne *\/ */
/*                         /\* $$.(*BinaryExpr).VectorMatching.Include = $3 *\/ */
/*                         /\* } *\/ */
/*                 | on_or_ignoring GROUP_RIGHT maybe_grouping_labels */
/*                         /\* { *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* $$.(*BinaryExpr).VectorMatching.Card = CardOneToMany *\/ */
/*                         /\* $$.(*BinaryExpr).VectorMatching.Include = $3 *\/ */
/*                         /\* } *\/ */
/*                 ; */


/* grouping_labels : LEFT_PAREN grouping_label_list RIGHT_PAREN */
/*                         /\* { $$ = $2 } *\/ */
/*                 | LEFT_PAREN grouping_label_list COMMA RIGHT_PAREN */
/*                         /\* { $$ = $2 } *\/ */
/*                 | LEFT_PAREN RIGHT_PAREN */
/*                         /\* { $$ = []string{} } *\/ */
/*                 | error */
/*                         /\* { yylex.(*parser).unexpected("grouping opts", "\"(\""); $$ = nil } *\/ */
/*                 ; */


/* grouping_label_list: */
/*                 grouping_label_list COMMA grouping_label */
/*                         /\* { $$ = append($1, $3.Val) } *\/ */
/*                 | grouping_label */
/*                         /\* { $$ = []string{$1.Val} } *\/ */
/*                 | grouping_label_list error */
/*                         /\* { yylex.(*parser).unexpected("grouping opts", "\",\" or \")\""); $$ = $1 } *\/ */
/*                 ; */

/* grouping_label  : maybe_label */
/*                         /\* { *\/ */
/*                         /\* if !isLabel($1.Val) { *\/ */
/*                         /\*         yylex.(*parser).unexpected("grouping opts", "label") *\/ */
/*                         /\* } *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* } *\/ */
/*                 | error */
/*                         /\* { yylex.(*parser).unexpected("grouping opts", "label"); $$ = Item{} } *\/ */
/*                 ; */

/* /\* */
/*  * Function calls. */
/*  *\/ */

/* function_call   : IDENTIFIER function_call_body */
/*                         /\* { *\/ */
/*                         /\* fn, exist := getFunction($1.Val) *\/ */
/*                         /\* if !exist{ *\/ */
/*                         /\*         yylex.(*parser).addParseErrf($1.PositionRange(),"unknown function with name %q", $1.Val) *\/ */
/*                         /\* } *\/ */
/*                         /\* $$ = &Call{ *\/ */
/*                         /\*         Func: fn, *\/ */
/*                         /\*         Args: $2.(Expressions), *\/ */
/*                         /\*         PosRange: PositionRange{ *\/ */
/*                         /\*                 Start: $1.Pos, *\/ */
/*                         /\*                 End:   yylex.(*parser).lastClosing, *\/ */
/*                         /\*         }, *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* function_call_body: LEFT_PAREN function_call_args RIGHT_PAREN */
/*                         /\* { $$ = $2 } *\/ */
/*                 | LEFT_PAREN RIGHT_PAREN */
/*                         /\* {$$ = Expressions{}} *\/ */
/*                 ; */

/* function_call_args: function_call_args COMMA expr */
/*                         /\* { $$ = append($1.(Expressions), $3.(Expr)) } *\/ */
/*                 | expr */
/*                         /\* { $$ = Expressions{$1.(Expr)} } *\/ */
/*                 | function_call_args COMMA */
/*                         /\* { *\/ */
/*                         /\* yylex.(*parser).addParseErrf($2.PositionRange(), "trailing commas not allowed in function call args") *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* /\* */
/*  * Expressions inside parentheses. */
/*  *\/ */

/* paren_expr      : LEFT_PAREN expr RIGHT_PAREN */
/*                         /\* { $$ = &ParenExpr{Expr: $2.(Expr), PosRange: mergeRanges(&$1, &$3)} } *\/ */
/*                 ; */

/* /\* */
/*  * Offset modifiers. */
/*  *\/ */

/* offset_expr: expr OFFSET duration */
/*                         /\* { *\/ */
/*                         /\* yylex.(*parser).addOffset($1, $3) *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* } *\/ */
/*                 | expr OFFSET SUB duration */
/*                         /\* { *\/ */
/*                         /\* yylex.(*parser).addOffset($1, -$4) *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* } *\/ */
/*                 | expr OFFSET error */
/*                         /\* { yylex.(*parser).unexpected("offset", "duration"); $$ = $1 } *\/ */
/*                 ; */
/* /\* */
/*  * @ modifiers. */
/*  *\/ */

/* step_invariant_expr: expr AT signed_or_unsigned_number */
/*                         /\* { *\/ */
/*                         /\* yylex.(*parser).setTimestamp($1, $3) *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* } *\/ */
/*                 | expr AT at_modifier_preprocessors LEFT_PAREN RIGHT_PAREN */
/*                         /\* { *\/ */
/*                         /\* yylex.(*parser).setAtModifierPreprocessor($1, $3) *\/ */
/*                         /\* $$ = $1 *\/ */
/*                         /\* } *\/ */
/*                 | expr AT error */
/*                         /\* { yylex.(*parser).unexpected("@", "timestamp"); $$ = $1 } *\/ */
/*                 ; */

/* at_modifier_preprocessors: START | END; */

/* /\* */
/*  * Subquery and range selectors. */
/*  *\/ */

/* matrix_selector : expr LEFT_BRACKET duration RIGHT_BRACKET */
/*                         /\* { *\/ */
/*                         /\* var errMsg string *\/ */
/*                         /\* vs, ok := $1.(*VectorSelector) *\/ */
/*                         /\* if !ok{ *\/ */
/*                         /\*         errMsg = "ranges only allowed for vector selectors" *\/ */
/*                         /\* } else if vs.OriginalOffset != 0{ *\/ */
/*                         /\*         errMsg = "no offset modifiers allowed before range" *\/ */
/*                         /\* } else if vs.Timestamp != nil { *\/ */
/*                         /\*         errMsg = "no @ modifiers allowed before range" *\/ */
/*                         /\* } *\/ */

/*                         /\* if errMsg != ""{ *\/ */
/*                         /\*         errRange := mergeRanges(&$2, &$4) *\/ */
/*                         /\*         yylex.(*parser).addParseErrf(errRange, errMsg) *\/ */
/*                         /\* } *\/ */

/*                         /\* $$ = &MatrixSelector{ *\/ */
/*                         /\*         VectorSelector: $1.(Expr), *\/ */
/*                         /\*         Range: $3, *\/ */
/*                         /\*         EndPos: yylex.(*parser).lastClosing, *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* subquery_expr   : expr LEFT_BRACKET duration COLON maybe_duration RIGHT_BRACKET */
/*                         /\* { *\/ */
/*                         /\* $$ = &SubqueryExpr{ *\/ */
/*                         /\*         Expr:  $1.(Expr), *\/ */
/*                         /\*         Range: $3, *\/ */
/*                         /\*         Step:  $5, *\/ */

/*                         /\*         EndPos: $6.Pos + 1, *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 | expr LEFT_BRACKET duration COLON duration error */
/*                         /\* { yylex.(*parser).unexpected("subquery selector", "\"]\""); $$ = $1 } *\/ */
/*                 | expr LEFT_BRACKET duration COLON error */
/*                         /\* { yylex.(*parser).unexpected("subquery selector", "duration or \"]\""); $$ = $1 } *\/ */
/*                 | expr LEFT_BRACKET duration error */
/*                         /\* { yylex.(*parser).unexpected("subquery or range", "\":\" or \"]\""); $$ = $1 } *\/ */
/*                 | expr LEFT_BRACKET error */
/*                         /\* { yylex.(*parser).unexpected("subquery selector", "duration"); $$ = $1 } *\/ */
/*                 ; */

/* /\* */
/*  * Unary expressions. */
/*  *\/ */

/* unary_expr      : */
/*                 /\* gives the rule the same precedence as MUL. This aligns with mathematical conventions *\/ */
/*                 unary_op expr %prec MUL */
/*                         /\* { *\/ */
/*                         /\* if nl, ok := $2.(*NumberLiteral); ok { *\/ */
/*                         /\*         if $1.Typ == SUB { *\/ */
/*                         /\*                 nl.Val *= -1 *\/ */
/*                         /\*         } *\/ */
/*                         /\*         nl.PosRange.Start = $1.Pos *\/ */
/*                         /\*         $$ = nl *\/ */
/*                         /\* } else { *\/ */
/*                         /\*         $$ = &UnaryExpr{Op: $1.Typ, Expr: $2.(Expr), StartPos: $1.Pos} *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* /\* */
/*  * Vector selectors. */
/*  *\/ */

/* vector_selector: metric_identifier label_matchers */
/*                         /\* { *\/ */
/*                         /\* vs := $2.(*VectorSelector) *\/ */
/*                         /\* vs.PosRange = mergeRanges(&$1, vs) *\/ */
/*                         /\* vs.Name = $1.Val *\/ */
/*                         /\* yylex.(*parser).assembleVectorSelector(vs) *\/ */
/*                         /\* $$ = vs *\/ */
/*                         /\* } *\/ */
/*                 | metric_identifier */
/*                         /\* { *\/ */
/*                         /\* vs := &VectorSelector{ *\/ */
/*                         /\*         Name: $1.Val, *\/ */
/*                         /\*         LabelMatchers: []*labels.Matcher{}, *\/ */
/*                         /\*         PosRange: $1.PositionRange(), *\/ */
/*                         /\* } *\/ */
/*                         /\* yylex.(*parser).assembleVectorSelector(vs) *\/ */
/*                         /\* $$ = vs *\/ */
/*                         /\* } *\/ */
/*                 | label_matchers */
/*                         /\* { *\/ */
/*                         /\* vs := $1.(*VectorSelector) *\/ */
/*                         /\* yylex.(*parser).assembleVectorSelector(vs) *\/ */
/*                         /\* $$ = vs *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* label_matchers  : LEFT_BRACE label_match_list RIGHT_BRACE */
/*                         /\* { *\/ */
/*                         /\* $$ = &VectorSelector{ *\/ */
/*                         /\*         LabelMatchers: $2, *\/ */
/*                         /\*         PosRange: mergeRanges(&$1, &$3), *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 | LEFT_BRACE label_match_list COMMA RIGHT_BRACE */
/*                         /\* { *\/ */
/*                         /\* $$ = &VectorSelector{ *\/ */
/*                         /\*         LabelMatchers: $2, *\/ */
/*                         /\*         PosRange: mergeRanges(&$1, &$4), *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 | LEFT_BRACE RIGHT_BRACE */
/*                         /\* { *\/ */
/*                         /\* $$ = &VectorSelector{ *\/ */
/*                         /\*         LabelMatchers: []*labels.Matcher{}, *\/ */
/*                         /\*         PosRange: mergeRanges(&$1, &$2), *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 ; */

/* label_match_list: label_match_list COMMA label_matcher */
/*                         /\* { *\/ */
/*                         /\* if $1 != nil{ *\/ */
/*                         /\*         $$ = append($1, $3) *\/ */
/*                         /\* } else { *\/ */
/*                         /\*         $$ = $1 *\/ */
/*                         /\* } *\/ */
/*                         /\* } *\/ */
/*                 | label_matcher */
/*                         /\* { $$ = []*labels.Matcher{$1}} *\/ */
/*                 | label_match_list error */
/*                         /\* { yylex.(*parser).unexpected("label matching", "\",\" or \"}\""); $$ = $1 } *\/ */
/*                 ; */

/* label_matcher   : IDENTIFIER match_op STRING */
/*                         /\* { $$ = yylex.(*parser).newLabelMatcher($1, $2, $3);  } *\/ */
/*                 | IDENTIFIER match_op error */
/*                         /\* { yylex.(*parser).unexpected("label matching", "string"); $$ = nil} *\/ */
/*                 | IDENTIFIER error */
/*                         /\* { yylex.(*parser).unexpected("label matching", "label matching operator"); $$ = nil } *\/ */
/*                 | error */
/*                         /\* { yylex.(*parser).unexpected("label matching", "identifier or \"}\""); $$ = nil} *\/ */
/*                 ; */

/* /\* */
/*  * Metric descriptions. */
/*  *\/ */

/* metric          : metric_identifier label_set */
/*                         /\* { $$ = append($2, labels.Label{Name: labels.MetricName, Value: $1.Val}); sort.Sort($$) } *\/ */
/*                 | label_set */
/*                         /\* {$$ = $1} *\/ */
/*                 ; */


/* metric_identifier: AVG | BOTTOMK | BY | COUNT | COUNT_VALUES | GROUP | IDENTIFIER |  LAND | LOR | LUNLESS | MAX | METRIC_IDENTIFIER | MIN | OFFSET | QUANTILE | STDDEV | STDVAR | SUM | TOPK | WITHOUT | START | END; */

/* label_set       : LEFT_BRACE label_set_list RIGHT_BRACE */
/*                         /\* { $$ = labels.New($2...) } *\/ */
/*                 | LEFT_BRACE label_set_list COMMA RIGHT_BRACE */
/*                         /\* { $$ = labels.New($2...) } *\/ */
/*                 | LEFT_BRACE RIGHT_BRACE */
/*                         /\* { $$ = labels.New() } *\/ */
/*                 | /\* empty *\/ */
/*                         /\* { $$ = labels.New() } *\/ */
/*                 ; */

/* label_set_list  : label_set_list COMMA label_set_item */
/*                         /\* { $$ = append($1, $3) } *\/ */
/*                 | label_set_item */
/*                         /\* { $$ = []labels.Label{$1} } *\/ */
/*                 | label_set_list error */
/*                         /\* { yylex.(*parser).unexpected("label set", "\",\" or \"}\"", ); $$ = $1 } *\/ */

/*                 ; */

/* label_set_item  : IDENTIFIER EQL STRING */
/*                         /\* { $$ = labels.Label{Name: $1.Val, Value: yylex.(*parser).unquoteString($3.Val) } } *\/ */
/*                 | IDENTIFIER EQL error */
/*                         /\* { yylex.(*parser).unexpected("label set", "string"); $$ = labels.Label{}} *\/ */
/*                 | IDENTIFIER error */
/*                         /\* { yylex.(*parser).unexpected("label set", "\"=\""); $$ = labels.Label{}} *\/ */
/*                 | error */
/*                         /\* { yylex.(*parser).unexpected("label set", "identifier or \"}\""); $$ = labels.Label{} } *\/ */
/*                 ; */

start -> Result<Expr, String>:
                string_literal { $1 }
                | number_literal { $1 }
;

/*
 * Series descriptions (only used by unit tests).
 */
/*
series_description: metric series_values;
series_values   :
                | series_values SPACE series_item
                | series_values SPACE
                | error
;

series_item     : BLANK
                | BLANK TIMES uint
                | series_value
                | series_value TIMES uint
                | series_value signed_number TIMES uint
;

series_value    : IDENTIFIER
                | number
                | signed_number
;
*/

/*
 * Keyword lists.
 */

aggregate_op -> StorageType:
                AVG { lexeme_to_token($1) }
                | BOTTOMK { lexeme_to_token($1) }
                | COUNT { lexeme_to_token($1) }
                | COUNT_VALUES { lexeme_to_token($1) }
                | GROUP { lexeme_to_token($1) }
                | MAX { lexeme_to_token($1) }
                | MIN { lexeme_to_token($1) }
                | QUANTILE { lexeme_to_token($1) }
                | STDDEV { lexeme_to_token($1) }
                | STDVAR { lexeme_to_token($1) }
                | SUM { lexeme_to_token($1) }
                | TOPK { lexeme_to_token($1) }
;

// inside of grouping options label names can be recognized as keywords by the lexer. This is a list of keywords that could also be a label name.
maybe_label -> StorageType:
                AVG { lexeme_to_token($1) }
                | BOOL { lexeme_to_token($1) }
                | BOTTOMK { lexeme_to_token($1) }
                | BY { lexeme_to_token($1) }
                | COUNT { lexeme_to_token($1) }
                | COUNT_VALUES { lexeme_to_token($1) }
                | GROUP { lexeme_to_token($1) }
                | GROUP_LEFT { lexeme_to_token($1) }
                | GROUP_RIGHT { lexeme_to_token($1) }
                | IDENTIFIER { lexeme_to_token($1) }
                | IGNORING { lexeme_to_token($1) }
                | LAND { lexeme_to_token($1) }
                | LOR { lexeme_to_token($1) }
                | LUNLESS { lexeme_to_token($1) }
                | MAX { lexeme_to_token($1) }
                | METRIC_IDENTIFIER { lexeme_to_token($1) }
                | MIN { lexeme_to_token($1) }
                | OFFSET { lexeme_to_token($1) }
                | ON { lexeme_to_token($1) }
                | QUANTILE { lexeme_to_token($1) }
                | STDDEV { lexeme_to_token($1) }
                | STDVAR { lexeme_to_token($1) }
                | SUM { lexeme_to_token($1) }
                | TOPK { lexeme_to_token($1) }
                | START { lexeme_to_token($1) }
                | END { lexeme_to_token($1) }
                | ATAN2 { lexeme_to_token($1) }
;

unary_op -> StorageType:
                ADD { lexeme_to_token($1) }
                | SUB { lexeme_to_token($1) }
;

match_op -> StorageType:
                EQL { lexeme_to_token($1) }
                | NEQ { lexeme_to_token($1) }
                | EQL_REGEX { lexeme_to_token($1) }
                | NEQ_REGEX { lexeme_to_token($1) }
;

/*
 * Literals.
 */

number_literal -> Result<Expr, String>:
                number { Ok(Expr::NumberLiteral { span: $span, val: $1?}) }
;


signed_or_unsigned_number -> Result<f64, String>:
                number { $1 }
                | signed_number  { $1 }
;


number -> Result<f64, String>:
                NUMBER
                {
                        let s = $lexer.span_str($span);
                        s.parse::<f64>().map_err(|_| format!("ParseFloatError. {} can't be parsed into f64", s))
                }
;

signed_number -> Result<f64, String>:
                ADD number { $2 }
                | SUB number { $2.map(|i| -i) }
;

uint -> Result<u64, String>:
                NUMBER
                {
                        let s = $lexer.span_str($span);
                        s.parse::<u64>().map_err(|_| format!("ParseIntError. {} can't be parsed into u64", s))
                }
;

duration -> Result<Duration, String>:
                DURATION
                { parse_duration($lexer.span_str($span)) }
;

string_literal -> Result<Expr, String>:
                STRING
                {
                        let val = span_to_string($lexer, $span)?;
                        Ok(Expr::StringLiteral { span: $span, val: val})
                }
;

/*
 * Wrappers for optional arguments.
 */

/* maybe_duration  : /\* empty *\/ */
/*                         {$$ = 0} */
/*                 | duration */
/*                 ; */

/* maybe_grouping_labels: /\* empty *\/ */
/*                 { $$ = nil } */
/*                 | grouping_labels */
/*                 ; */

%%

use std::time::{Duration, Instant};

use crate::parser::{lexeme_to_string, span_to_string, lexeme_to_token};
use crate::parser::{Expr, LexemeType, StorageType};
use crate::parser::value::{NORMAL_NAN, STALE_NAN, STALE_STR};

use crate::util::parse_duration;
