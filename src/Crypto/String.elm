----------------------------------------------------------------------
--
-- String.elm
-- Top-level default string functions for elm-crypto-string.
-- Copyright (c) 2017 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------


module Crypto.String
    exposing
        ( Key
        , decrypt
        , dummyGenerator
        , encrypt
        , expandKeyString
        )

{-| Block chaining and string encryption for use with any block cipher.


# Types

@docs Key


# Functions

@docs expandKeyString, dummyGenerator, encrypt, decrypt

-}

import Array
import Crypto.String.BlockAes as Aes
import Crypto.String.Crypt as Crypt
import Crypto.String.Types as Types


{-| Key
-}
type alias Key =
    Types.Key Aes.Key


config =
    Crypt.defaultConfig


{-| Expand a key preparing it for use with `encrypt` or `decrypt`.
-}
expandKeyString : String -> Result String Key
expandKeyString string =
    Crypt.expandKeyString config string


{-| A dummy random generator that isn't random
-}
dummyGenerator : Types.RandomGenerator ()
dummyGenerator blockSize =
    ( (), Array.initialize blockSize identity )


{-| Encrypt a string. Encode the output as Base64 with 80-character lines.

Use `Crypto.String.Crypt` for more options.

-}
encrypt : Types.RandomGenerator randomState -> Key -> String -> ( randomState, String )
encrypt generator key =
    Crypt.encrypt config generator key


{-| Decrypt a string created with `encrypt`.

Use `Crypto.String.Crypt` for more options.

-}
decrypt : Key -> String -> String
decrypt key =
    Crypt.decrypt config key
