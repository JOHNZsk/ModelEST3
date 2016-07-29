unit LoadConfig;

interface
  uses LogikaStavadlo;

  type TConfigLoader=class(TObject)
    private
      t_nazov: string;

    public
      constructor Create(p_nazov: string);
      procedure NacitajKonfiguraciu(p_ciel: TLogikaES);
  end;

implementation
  constructor TConfigLoader.Create(p_nazov: string);
  begin
    inherited;

    t_nazov:=p_nazov;
  end;

  //////////////////////////////////////////////////////////////////////////////

  procedure TConfigLoader.NacitajKonfiguraciu(p_ciel: TLogikaES);
  begin

  end;

end.
