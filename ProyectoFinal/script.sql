create table administracion
(
    id_admin int auto_increment
        primary key,
    nombre   varchar(100) not null,
    apellido varchar(100) not null,
    emial    varchar(100) not null,
    cargo    varchar(50)  not null
);

create table marca_disp
(
    id_marca int auto_increment
        primary key,
    marca    varchar(100) not null
);

create table productos
(
    id_disp    int auto_increment
        primary key,
    id_marca   int         not null,
    tipo       varchar(30) not null,
    nombre_pro varchar(50) not null,
    CANTIDAD   int         null,
    constraint productos_ibfk_1
        foreign key (id_marca) references marca_disp (id_marca)
);

create table caracteristicas_disp
(
    num_disp          int auto_increment
        primary key,
    id_disp           int          not null,
    procesador        varchar(30)  not null,
    ram               varchar(30)  not null,
    almacenamiento    varchar(30)  not null,
    pantalla          varchar(30)  not null,
    bateria           varchar(30)  not null,
    sistema_operativo varchar(200) not null,
    camara            varchar(20)  not null,
    constraint caracteristicas_disp_ibfk_1
        foreign key (id_disp) references productos (id_disp)
);

create index id_disp
    on caracteristicas_disp (id_disp);

create table clientes
(
    ci       varchar(20)  not null
        primary key,
    nombre   varchar(100) not null,
    apellido varchar(100) not null,
    emial    varchar(100) not null,
    servicio varchar(100) not null,
    id_disp  int          not null,
    estado   varchar(10)  null,
    constraint clientes_ibfk_1
        foreign key (id_disp) references productos (id_disp)
);

create index id_disp
    on clientes (id_disp);

create definer = root@localhost trigger servicio
    before insert
    on clientes
    for each row
BEGIN
        IF NEW.servicio='compra' OR NEW.servicio='tecnico'
            THEN
            SET NEW.estado='VERIFICADO';
        ELSE
            SET NEW.estado='A VERIFICAR';
        end if;
END;

create table precios
(
    num_disp      int auto_increment
        primary key,
    precio_normal int not null,
    descuento     int not null,
    constraint precios_ibfk_1
        foreign key (num_disp) references caracteristicas_disp (num_disp)
);

create index id_marca
    on productos (id_marca);

create table recibo
(
    numero_compra int auto_increment
        primary key,
    ci_cliente    varchar(20) not null,
    id_admin      int         not null,
    id_disp       int         not null,
    pago          int         not null,
    fecha         date        not null,
    constraint recibo_ibfk_1
        foreign key (ci_cliente) references clientes (ci),
    constraint recibo_ibfk_2
        foreign key (id_admin) references administracion (id_admin),
    constraint recibo_ibfk_3
        foreign key (id_disp) references productos (id_disp)
);

create index ci_cliente
    on recibo (ci_cliente);

create index id_admin
    on recibo (id_admin);

create index id_disp
    on recibo (id_disp);

create table tabla_auxiliar
(
    id_disp  int null,
    cantidad int null
);

create definer = root@localhost trigger contarDatos
    after insert
    on tabla_auxiliar
    for each row
    UPDATE productos
SET cantidad = productos.cantidad + new.cantidad
where productos.id_disp =new.id_disp;

create definer = root@localhost view compra as
select `cli`.`ci`       AS `ci`,
       `cli`.`nombre`   AS `nombre`,
       `cli`.`apellido` AS `apellido`,
       `cli`.`emial`    AS `emial`,
       `cli`.`servicio` AS `servicio`,
       `cli`.`id_disp`  AS `id_disp`,
       `r`.`id_admin`   AS `id_admin`,
       `r`.`fecha`      AS `fecha`
from (`apk_phone`.`clientes` `cli` join `apk_phone`.`recibo` `r` on (`cli`.`ci` = `r`.`ci_cliente`));

create definer = root@localhost view gama_segun_precio as
select `prod`.`nombre_pro`                                         AS `nombre`,
       `mar`.`marca`                                               AS `marca`,
       `prod`.`tipo`                                               AS `tipo`,
       `pre`.`precio_normal`                                       AS `precio`,
       case
           when `pre`.`precio_normal` > 10 and `pre`.`precio_normal` <= 150 then 'Gama Basica'
           when `pre`.`precio_normal` > 150 and `pre`.`precio_normal` <= 500 then 'Gama Intermedia'
           when `pre`.`precio_normal` > 500 and `pre`.`precio_normal` <= 800 then 'Gama Alta'
           when `pre`.`precio_normal` > 800 then 'Gama Alta++' end AS `gama`
from (((`apk_phone`.`precios` `pre` join `apk_phone`.`caracteristicas_disp` `carac`
        on (`pre`.`num_disp` = `carac`.`num_disp`)) join `apk_phone`.`productos` `prod`
       on (`carac`.`id_disp` = `prod`.`id_disp`)) join `apk_phone`.`marca_disp` `mar`
      on (`prod`.`id_marca` = `mar`.`id_marca`));

create definer = root@localhost view informacion as
select `pro`.`id_disp`          AS `id_disp`,
       `pro`.`nombre_pro`       AS `nombre_pro`,
       `pro`.`id_marca`         AS `id_marca`,
       `pro`.`tipo`             AS `tipo`,
       `cd`.`procesador`        AS `procesador`,
       `cd`.`ram`               AS `ram`,
       `cd`.`almacenamiento`    AS `almacenamiento`,
       `cd`.`pantalla`          AS `pantalla`,
       `cd`.`bateria`           AS `bateria`,
       `cd`.`sistema_operativo` AS `sistema_operativo`,
       `cd`.`camara`            AS `camara`
from ((`apk_phone`.`productos` `pro` join `apk_phone`.`caracteristicas_disp` `cd`
       on (`pro`.`id_disp` = `cd`.`id_disp`)) join `apk_phone`.`marca_disp` `md`
      on (`pro`.`id_marca` = `md`.`id_marca`));

create definer = root@localhost view productos_por_marca as
select `mar`.`id_marca`    AS `id_marca`,
       `pro`.`nombre_pro`  AS `nombre_pro`,
       `mar`.`marca`       AS `marca`,
       `pro`.`tipo`        AS `tipo`,
       `p`.`precio_normal` AS `precio_normal`,
       `p`.`descuento`     AS `descuento`,
       `pro`.`id_disp`     AS `id_disp`,
       `p`.`num_disp`      AS `num_disp`
from (((`apk_phone`.`productos` `pro` join `apk_phone`.`marca_disp` `mar`
        on (`pro`.`id_marca` = `mar`.`id_marca`)) join `apk_phone`.`caracteristicas_disp` `cd`
       on (`pro`.`id_disp` = `cd`.`id_disp`)) join `apk_phone`.`precios` `p` on (`cd`.`num_disp` = `p`.`num_disp`));

create
    definer = root@localhost procedure admi_trabajador()
BEGIN
        SELECT CONCAT(ad.nombre,' ',ad.apellido) AS ADMINISTRADOR, COUNT(re.id_admin) AS CANTIDAD
        FROM recibo AS re
        INNER JOIN administracion AS ad ON ad.id_admin = re.id_admin
        GROUP BY re.id_admin, ad.nombre, ad.apellido, ad.id_admin
        ORDER BY COUNT(2);
    end;

create
    definer = root@localhost procedure marca_mas_comprada()
BEGIN
    SELECT ma.marca, COUNT(cli.id_disp) AS CANTIDAD
    FROM clientes AS cli
    INNER JOIN productos AS pro ON cli.id_disp = pro.id_disp
    INNER JOIN marca_disp AS ma ON pro.id_marca = ma.id_marca
    GROUP BY ma.marca
    ORDER BY COUNT(2);
end;

create
    definer = root@localhost function pro_ven(dato int) returns int
BEGIN
        DECLARE respuesta INT;
        SET respuesta = (
            SELECT COUNT(ci.id_admin)
            FROM recibo AS ci
            WHERE id_admin = dato
            );
        RETURN respuesta;
    end;

create
    definer = root@localhost procedure top_ventas_REALIZADAS()
BEGIN
    SELECT CONCAT(pro.nombre_pro,' DE ',mar.marca)AS AUTO_MAS_COMPRADO ,COUNT(cli.id_disp) AS cantidad_de_ventas
        FROM clientes AS cli
        INNER JOIN productos AS pro on cli.id_disp = pro.id_disp
        INNER JOIN recibo AS re on cli.ci = re.ci_cliente
        INNER JOIN marca_disp AS mar ON mar.id_marca = pro.id_marca
        GROUP BY cli.id_disp,pro.nombre_pro
        ORDER BY COUNT(2) LIMIT 5;
end;


