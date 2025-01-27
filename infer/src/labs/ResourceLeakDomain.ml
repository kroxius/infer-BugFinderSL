(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open! IStd
module F = Format

module FiniteBounds = struct
  type t = int

  let leq ~lhs ~rhs = lhs <= rhs

  let join a b = max a b

  let widen ~prev ~next ~num_iters:_ = join prev next

  let pp fmt num = F.fprintf fmt "%d" num
end

include AbstractDomain.TopLifted (FiniteBounds)
open AbstractDomain.Types

let widening_threshold = 5

let widen ~prev ~next ~num_iters =
  match (prev, next) with
  | Top, _ | _, Top -> Top
  | NonTop prev, NonTop next when num_iters < widening_threshold -> NonTop (FiniteBounds.join prev next)
  | NonTop _, NonTop _ -> Top

let initial = NonTop 0

let acquire_resource = function Top -> Top | NonTop num -> NonTop (num + 1)
let release_resource = function Top -> Top | NonTop num -> NonTop (num - 1)
let has_leak = function
  | Top -> false
  | NonTop x when x > 0 -> true
  | NonTop _ -> false

  type summary = t
