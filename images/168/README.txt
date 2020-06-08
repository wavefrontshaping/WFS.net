To open the archives, use the following commands:

with bz2.BZ2File(path,'r') as save_file: 
	save_dict = pickle.load(save_file)

Be careful to change the protocol used by pickle if you work with python 3