# Portal image. Build context is the repository root.
# Build:  az acr build --registry <acr> --image portal:<sha> --file src/Allocation.Portal/Dockerfile .

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /repo

# 1. Restore first, using only project and build files, so this layer is cached
COPY global.json Directory.Build.props Directory.Packages.props ./
COPY src/Allocation.Shared/Allocation.Shared.csproj src/Allocation.Shared/
COPY src/Allocation.Portal/Allocation.Portal.csproj src/Allocation.Portal/
RUN dotnet restore src/Allocation.Portal/Allocation.Portal.csproj

# 2. Then copy the sources and publish.
# One COPY on purpose: Allocation.Shared has no source files yet, so a separate COPY of it
# creates an empty layer, which the classic builder used by ACR Tasks fails to export.
COPY src/ src/
RUN dotnet publish src/Allocation.Portal/Allocation.Portal.csproj \
    -c Release -o /app --no-restore /p:UseAppHost=false

# Runtime image: ASP.NET only, no SDK, non-root user, listens on 8080
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app .
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "Allocation.Portal.dll"]
