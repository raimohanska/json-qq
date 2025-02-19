{-# OPTIONS_GHC -XDeriveDataTypeable -XTemplateHaskell -XQuasiQuotes #-}
module JSON.TestQQ where

import JSON.QQ

-- for test
import Test.Framework.TH
import Test.Framework.Providers.HUnit
import Test.HUnit
import Test.Framework.Providers.QuickCheck2
import Test.Framework (defaultMain)

import Text.JSON
import Text.JSON.Types
import Text.JSON.Generic

import Data.Ratio

import Data.Char

-- import Data.Ratio

import Language.Haskell.TH 

main = $defaultMainGenerator

-- main = defaultMain [tests]

-- tests = $testGroupGenerator

case_get_QQ_to_compile = do
  let actual = [jsonQQ| {foo: "ba r.\".\\.r\n"} |]
      expected = JSObject $ toJSObject [("foo", JSString $ toJSString "ba r.\\\".\\\\.r\\n")]
  expected @=? actual

case_arrays = do
  let actual = [jsonQQ| [null,{foo: -42}] |]
      expected = JSArray [JSNull, JSObject $ toJSObject [("foo", JSRational False (-42 % 1))] ]
  expected @=? actual

case_code = do
  let actual = [jsonQQ| [null,{foo: <|x|>}] |]
      expected = JSArray [JSNull, JSObject $ toJSObject [("foo", JSRational False (42 % 1))] ]
      x = 42 :: Integer
  expected @=? actual

case_true = do
  let actual = [jsonQQ| [true,false,null] |]
      expected = JSArray [JSBool True, JSBool False, JSNull]
  expected @=? actual

case_json_var = do
  let actual = [jsonQQ| [null,{foo: <<x>>}] |]
      expected = JSArray [JSNull, JSObject $ toJSObject [("foo", JSRational False (42 % 1))] ]
      x = toJSON ( 42 :: Integer)
  expected @=? actual

case_foo = do
  let actual = [jsonQQ| <|foo|> |]
      expected = JSObject $ toJSObject [("age", JSRational False (42 % 1) ) ]
      foo = Bar 42
  expected @=? actual

case_quoted_name = do
  let actual = [jsonQQ| {"foo": "bar"} |]
      expected = JSObject $ toJSObject [("foo", JSString $ toJSString "bar")]
      foo = "zoo"
  expected @=? actual

case_var_name = do
  let actual = [jsonQQ| {$foo: "bar"} |]
      expected = JSObject $ toJSObject [("zoo", JSString $ toJSString "bar")]
      foo = "zoo"
  expected @=? actual

case_multiline = do
  let actual =
        [jsonQQ|
          [   {
            user: 
              "Pelle"},
           {user: "Arne"}]
         |]
      expected = JSArray [JSObject $ toJSObject [("user", JSString $ toJSString "Pelle")], JSObject $ toJSObject [ ("user", JSString $ toJSString "Arne")] ]
  expected @=? actual

case_simple_code = do
  let actual = [jsonQQ| { foo: <| foo |> } |]
      expected = JSObject $ toJSObject [("foo", JSString $ toJSString "zoo")]
      foo = "zoo"
  expected @=? actual

case_semi_advanced_code = do
  let actual = [jsonQQ| { foo: <| foo + 45 |> } |]
      expected = JSObject $ toJSObject [("foo", JSRational False (133 % 1))]
      foo = 88 :: Integer
  expected @=? actual


case_semi_advanced_char = do
  let actual = [jsonQQ| { name: <| map toUpper name |> } |]
      expected = JSObject $ toJSObject [("name", JSString $ toJSString "PELLE")]
      name = "Pelle" 
  expected @=? actual

-- Data types

data Foo = Bar { age :: Integer}
  deriving (Eq, Show, Typeable, Data)
