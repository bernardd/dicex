Unreleased
* Add exploding dice
* Add multiple separate roles delimited by commas
* Fix `*` and `/` evaluating right to left (e.g. `6*2/3` gave 0, now gives 4)
* Fix `0dN` rolling two dice instead of none
* Return bare constants (e.g. `"5"`) as `{[], 5}` like every other result
* Correct the `roll/1` typespec to `{:ok, roll_list()}`

v0.2.0
* Change return type, improve error handling

v0.1.0
* Initial release
