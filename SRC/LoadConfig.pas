unit LoadConfig;

interface
  type TConfigLoader=class(TObject)
    private
      t_nazov: string;

    public
      constructor Create(p_nazov: string);
  end;

implementation
  constructor TConfigLoader.Create(p_nazov: string);
  begin
    inherited;

    t_nazov:=p_nazov;
  end;

end.
