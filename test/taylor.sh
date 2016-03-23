#!/bin/bash

input="f(x)=sum_(n=0)^oo(f^((n))(a))/(n!)(x-a)^n";
expected="<math><mi>f</mi><mrow><mo>(</mo><mi>x</mi><mo>)</mo></mrow><mo>=</mo><munderover><mo>&Sigma;</mo><mrow><mi>n</mi><mo>=</mo><mn>0</mn></mrow><mo>&infin;</mo></munderover><mfrac><mrow><msup><mi>f</mi><mrow><mrow><mo>(</mo><mi>n</mi><mo>)</mo></mrow></mrow></msup><mrow><mo>(</mo><mi>a</mi><mo>)</mo></mrow></mrow><mrow><mi>n</mi><mo>!</mo></mrow></mfrac><msup><mrow><mo>(</mo><mi>x</mi><mo>&minus;</mo><mi>a</mi><mo>)</mo></mrow><mi>n</mi></msup></math>";
output=`echo -n "$input" | build/amath`

if [[ "$output" == "$expected" ]]; then
	echo "PASS: $0"
else
	echo "FAIL: $0 (expected $expected but got $output)"
fi