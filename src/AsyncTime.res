let wait = (duration: int) =>
  Promise.make((resolve, _) => {
    let _ = setTimeout(() => resolve(. ()), duration)
  })
