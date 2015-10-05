var fn = function () {
  console.log(this);

  console.log(arguments[0])

  console.log(arguments[1])
};

fn2 = fn.bind({a: 'a'}, 'b');

fn2('c')
