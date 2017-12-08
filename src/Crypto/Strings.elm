----------------------------------------------------------------------
--
-- Strings.elm
-- Top-level default string functions for elm-crypto-string.
-- Copyright (c) 2017 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------


module Crypto.Strings
    exposing
        ( RandomGenerator
        , decrypt
        , encrypt
        , justEncrypt
        , seedGenerator
        )

{-| Block chaining and string encryption for use with any block cipher.


# Types

@docs RandomGenerator


# Functions

@docs encrypt, justEncrypt, decrypt, seedGenerator

-}

import Array
import Crypto.Strings.Crypt as Crypt
import Crypto.Strings.Types as Types
import Random exposing (Seed)


config =
    Crypt.defaultConfig


{-| A function to generate randomState and an Array of bytes.
-}
type alias RandomGenerator randomState =
    Types.RandomGenerator randomState


{-| A dummy random generator that creates a block of zeroes.

This is about as non-random as it gets.

-}
seedGenerator : Seed -> RandomGenerator Seed
seedGenerator =
    Crypt.seedGenerator


{-| Encrypt a string. Encode the output as Base64 with 80-character lines.

See `Crypto.Strings.Crypt.encrypt` for more options.

This shouldn't ever return an error, but since the key generation can possibly do so, it returns a Result instead of just (String, randomState).

-}
encrypt : Seed -> String -> String -> Result String ( String, Seed )
encrypt seed passphrase plaintext =
    case Crypt.expandKeyString config passphrase of
        Err msg ->
            Err msg

        Ok key ->
            Ok <| Crypt.encrypt config (seedGenerator seed) key plaintext


{-| Testing function. Just returns the result with no random generator update.
-}
justEncrypt : Seed -> String -> String -> String
justEncrypt seed passphrase plaintext =
    case Crypt.expandKeyString config passphrase of
        Err msg ->
            ""

        Ok key ->
            Crypt.encrypt config (seedGenerator seed) key plaintext
                |> Tuple.first


{-| Decrypt a string created with `encrypt`.

See `Crypto.Strings.Crypt.decrypt` for more options.

This can get errors if the ciphertext you pass in decrypts to something that isn't a UTF-8 string.

-}
decrypt : String -> String -> Result String String
decrypt passphrase ciphertext =
    case Crypt.expandKeyString config passphrase of
        Err msg ->
            Err msg

        Ok key ->
            Crypt.decrypt config key ciphertext
