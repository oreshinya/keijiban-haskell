{-# LANGUAGE DeriveGeneric #-}
module Controllers.Topics.Params where

import GHC.Generics (Generic)
import Data.Aeson
import Data.Validator

data Params = Params { name :: Maybe String } deriving (Generic, Show)
data CheckedParams = CheckedParams { cName :: String } deriving (Show)

instance FromJSON Params

checkName :: Monad m => TransValidationRuleT String m (Maybe String) String
checkName = requiredValue "Name is required."
        >=> notEmpty "Name is required."
        >=> maxLength 30 "Name is less than 30 charactors."

checkParams :: Monad m => TransValidationRuleT String m Params CheckedParams
checkParams (Params n) = CheckedParams <$> checkName n

validateParams :: Params -> Either String CheckedParams
validateParams p = runValidator checkParams $ p
