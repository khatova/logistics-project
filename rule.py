class Rule():
    def __init__(self,first_p,first_v,second_p,second_v):
        self.first_parameter = str(first_p)
        self.first_value = str(first_v)
        self.second_parameter = str(second_p)
        self.second_value = str(second_v)

    def to_string(self):
        line = 'init(object({0},{1}),value({2},{3})).'.format(self.first_parameter, self.first_value,
                                                            self.second_parameter, self.second_value)
        return line + '\n'