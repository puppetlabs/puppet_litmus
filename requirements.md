1. attach to a parameter call target:
2. Target should accept strings that are defined as
  a. Specific Target URIs
  b. An inventory group name
  c. The name of a role
3. The parameter should accept either or both of string or symbol
4. The parameter should accept a single value or an array
5. The search for a target name should
  a. Should be tolerant to role values that are either a single value or an array of roles
  b. Should be tolerant to the role variable being called either `role` or `roles`

There is a possibility that if multiple single targets are returned, the format of the value given to the BoltSpec function will have to be changed or constructed in a specific way.