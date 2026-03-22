# Cómo Publicar un Arquetipo Maven

Un **arquetipo Maven** es una plantilla de proyecto que permite generar nuevos proyectos con una estructura y configuración predefinidas. A continuación, te presentamos una guía completa para crear, empaquetar y publicar un arquetipo Maven.

---

## 1. Crear el Arquetipo

### Opción A: Desde un proyecto existente

```bash
mvn archetype:create-from-project
```

Esto genera un arquetipo basado en tu proyecto actual en `target/generated-sources/archetype`.

### Opción B: Crear desde cero

```bash
mvn archetype:generate \
  -DgroupId=com.ejemplo \
  -DartifactId=mi-arquetipo \
  -Dversion=1.0.0 \
  -Dpackage=com.ejemplo.template \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false
```

---

## 2. Estructura del Arquetipo

```
mi-arquetipo/
├── pom.xml
└── src/
    └── main/
        └── resources/
            ├── META-INF/
            │   └── maven/
            │       └── archetype-metadata.xml
            └── archetype-resources/
                ├── pom.xml
                └── src/
```

### archetype-metadata.xml (ejemplo)

```xml
<archetype-descriptor name="mi-arquetipo">
  <fileSets>
    <fileSet filtered="true" packaged="true">
      <directory>src/main/java</directory>
    </fileSet>
    <fileSet filtered="true">
      <directory>src/main/resources</directory>
    </fileSet>
  </fileSets>
</archetype-descriptor>
```

---

## 3. Configurar el pom.xml del Arquetipo

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.ejemplo</groupId>
  <artifactId>mi-arquetipo</artifactId>
  <version>1.0.0</version>
  <packaging>maven-archetype</packaging>

  <build>
    <extensions>
      <extension>
        <groupId>org.apache.maven.archetype</groupId>
        <artifactId>archetype-packaging</artifactId>
        <version>3.2.1</version>
      </extension>
    </extensions>

    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-archetype-plugin</artifactId>
        <version>3.2.1</version>
      </plugin>
    </plugins>
  </build>

  <distributionManagement>
    <repository>
      <id>repositorio-prod</id>
      <url>https://tu-repositorio.com/releases</url>
    </repository>
    <snapshotRepository>
      <id>repositorio-snap</id>
      <url>https://tu-repositorio.com/snapshots</url>
    </snapshotRepository>
  </distributionManagement>
</project>
```

---

## 4. Empaquetar el Arquetipo

```bash
mvn clean install
```

Esto genera el archivo `.jar` del arquetipo en tu repositorio local.

---

## 5. Publicar el Arquetipo

### A. En Repositorio Local

```bash
mvn install
```

### B. En Repositorio Remoto Privado

Configura `settings.xml` (~/.m2/settings.xml):

```xml
<settings>
  <servers>
    <server>
      <id>repositorio-prod</id>
      <username>tu-usuario</username>
      <password>tu-contraseña</password>
    </server>
  </servers>
</settings>
```

Luego ejecuta:

```bash
mvn deploy
```

### C. En Maven Central (Sonatype)

1. Regístrate en [https://issues.sonatype.org](https://issues.sonatype.org)
2. Configura GPG para firmar artefactos
3. Añade al `pom.xml`:

```xml
<profiles>
  <profile>
    <id>release</id>
    <build>
      <plugins>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-gpg-plugin</artifactId>
          <version>3.0.1</version>
          <executions>
            <execution>
              <id>sign-artifacts</id>
              <phase>verify</phase>
              <goals>
                <goal>sign</goal>
              </goals>
            </execution>
          </executions>
        </plugin>
        <plugin>
          <groupId>org.sonatype.plugins</groupId>
          <artifactId>nexus-staging-maven-plugin</artifactId>
          <version>1.6.13</version>
          <extensions>true</extensions>
          <configuration>
            <serverId>ossrh</serverId>
            <nexusUrl>https://oss.sonatype.org/</nexusUrl>
            <autoReleaseAfterClose>true</autoReleaseAfterClose>
          </configuration>
        </plugin>
      </plugins>
    </build>
  </profile>
</profiles>
```

4. Despliega con:

```bash
mvn clean deploy -P release
```

---

## 6. Usar el Arquetipo Publicado

### Desde repositorio local o remoto configurado:

```bash
mvn archetype:generate \
  -DarchetypeGroupId=com.ejemplo \
  -DarchetypeArtifactId=mi-arquetipo \
  -DarchetypeVersion=1.0.0 \
  -DgroupId=com.nuevo \
  -DartifactId=mi-proyecto \
  -DinteractiveMode=false
```

### Agregar catálogo remoto (opcional):

```bash
mvn archetype:catalog-update \
  -Dcatalog=https://tu-repositorio.com/archetype-catalog.xml
```

---

## 7. Verificar la Publicación

- **Repositorio local:** `~/.m2/repository/com/ejemplo/mi-arquetipo/`
- **Repositorio remoto:** Accede vía navegador o CLI al URL configurado
- **Maven Central:** [https://search.maven.org](https://search.maven.org)

---

## 8. Buenas Prácticas

✅ Usa versionamiento semántico (ej. 1.0.0)  
✅ Documenta las propiedades del arquetipo  
✅ Prueba el arquetipo antes de publicarlo  
✅ Firma los artefactos para Maven Central  
✅ Mantén un CHANGELOG de versiones  

❌ No publiques versiones SNAPSHOT en producción  
❌ No omitas la firma GPG en Maven Central  
❌ No uses nombres genéricos para groupId/artifactId  

---

Con estos pasos podrás crear, empaquetar y publicar un arquetipo Maven de forma profesional, ya sea en un repositorio privado o en Maven Central.