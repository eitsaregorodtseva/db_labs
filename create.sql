CREATE TABLE transport (
  license_number CHAR(10) CONSTRAINT transport_pk PRIMARY KEY,
  brand VARCHAR(20) NOT NULL,
  capacity INT NOT NULL
);

CREATE TABLE drivers (
  did CHAR(10) CONSTRAINT drivers_pk PRIMARY KEY,
  fio VARCHAR(30) NOT NULL,
  dclass INT NOT NULL,
  license_number CHAR(10) CONSTRAINT transport_fk REFERENCES transport
);

CREATE TABLE routes (
  rid NUMERIC(4, 0) CONSTRAINT routes_pk PRIMARY KEY,
  departure VARCHAR(50) NOT NULL,
  arrival VARCHAR(50) NOT NULL,
  dep_time TIME NOT NULL,
  duration INTERVAL NOT NULL,
  rperiod CHAR(10) CONSTRAINT rperiod_check CHECK(rperiod IN ('ED', 'EN', 'ON', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU' )),
  price NUMERIC(6, 2) CONSTRAINT price_check CHECK(price > 0)
);

CREATE TABLE voyages (
  rid NUMERIC(4, 0) CONSTRAINT routes_fk REFERENCES routes,
  dep_date DATE NOT NULL,
  did CHAR(10) CONSTRAINT drivers_fk REFERENCES drivers,
  tickets INT NOT NULL
);
