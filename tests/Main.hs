module Main where

import Data.List
import Data.Maybe
import Control.Monad
import System.Exit
import System.IO
import Math.Spe

data Equality a b c = Equality
    { name :: String
    , lhs  :: Spe a b
    , rhs  :: Spe a c
    , iso  :: b -> c
    }

checkContact :: Ord c => Int -> Equality Int b c -> IO Bool
checkContact n (Equality name lhs rhs iso) = do
    putStr (name ++ ": ") >> hFlush stdout
    let haveContact = contact n (map iso . lhs) rhs
    putStrLn (if haveContact then "PASS" else "FAIL") >> hFlush stdout
    return haveContact

passOrFail :: [IO Bool] -> IO a
passOrFail [] = exitSuccess
passOrFail (m:ms) = flip unless exitFailure `liftM` m >> passOrFail ms

main = passOrFail
    [ checkContact 5 Equality
        { name = "dx cyc ~= list"
        , lhs  = dx cyc
        , rhs  = list
        , iso  = catMaybes
        }
    , checkContact 5 Equality
        { name = "list .*. list ~= dx list"
        , lhs  = list .*. list
        , rhs  = dx list
        , iso  = \(us, vs) -> map Just us ++ Nothing : map Just vs
        }
    , checkContact 12 Equality
        { name = "pointed set ~= x .*. dx set"
        , lhs  = pointed set
        , rhs  = x .*. dx set
        , iso  = \(us, u) -> (u, Nothing : map Just (us \\ [u]))
        }
    , checkContact 8 Equality
        { name = "set >< (x .*. set) ~= pointed set"
        , lhs  = set >< (x .*. set)
        , rhs  = pointed set
        , iso  = \(p, (u,_)) -> (p, u)
        }
    , checkContact 8 Equality
        { name = "par >< (x .*. set) ~= pointed par"
        , lhs  = par >< (x .*. set)
        , rhs  = pointed par
        , iso  = \(p, (u,_)) -> (p, u)
        }
    , checkContact 8 Equality
        { name = "set `o` nonEmpty set ~= par"
        , lhs  = set `o` nonEmpty set
        , rhs  = par
        , iso  = fst
        }
    , checkContact 6 Equality
        { name = "list `o` nonEmpty set ~= bal"
        , lhs  = list `o` nonEmpty set
        , rhs  = bal
        , iso  = fst
        }
    ]
