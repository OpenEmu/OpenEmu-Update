char hh,mm,ss,_f,_fps,_foo;
fps(){
	_foo=ss;
	hh=clock_hh();mm=clock_mm();ss=clock_ss();
	_f++;
	if(ss!=_foo){
		_fps=_f;
		_f=0;

    	put_number(_fps,2,15,27);		
	}
}
