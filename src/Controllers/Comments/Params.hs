{-# LANGUAGE DeriveGeneric #-}
module Controllers.Comments.Params where

import GHC.Generics (Generic)
import Data.Aeson
import Data.Validator

data Params = Params { body :: Maybe String } deriving (Generic, Show)
data CheckedParams = CheckedParams { cBody :: String } deriving (Show)

instance FromJSON Params

checkBody :: Monad m => TransValidationRuleT String m (Maybe String) String
checkBody = requiredValue "Body is required."
        >=> notEmpty "Body is required."

checkParams :: Monad m => TransValidationRuleT String m Params CheckedParams
checkParams (Params b) = CheckedParams <$> checkBody b

validateParams :: Params -> Either String CheckedParams
validateParams p = runValidator checkParams $ p
