#!/bin/bash
cleanup() {
  rm -rvf "${FUNC_TEST_DIR}"
}

create_version() {
  local version="$1"

  echo "[${version}] Creating environment..."

  create_project "${version}"
  install_shipper "${version}"
  sync_shipper "${version}"
  add_provider "${version}"
}

create_project() {
  local version="$1"
  local versionDir="${FUNC_TEST_DIR}/${version}"

  if [ ! -d "${versionDir}/vendor" ]; then
    echo "[${version}] Creating project..."
    if [ -n "$DEBUG" ]; then
      $COMPOSER_BIN create-project laravel/laravel "${versionDir}" "${version}"
    else
      $COMPOSER_BIN create-project laravel/laravel "${versionDir}" "${version}" > /dev/null
    fi
  fi
}

install_shipper() {
  local version="$1"
  local versionDir="${FUNC_TEST_DIR}/${version}"

  cd "${versionDir}"
  if [ ! -d vendor/x3tech/laravel-shipper ]; then
    echo "[${version}] Installing laravel-shipper..."
    if [ -n "$DEBUG" ]; then
      $COMPOSER_BIN require --prefer-source "x3tech/laravel-shipper dev-${BRANCH}" > /dev/null
    else
      $COMPOSER_BIN require --prefer-source "x3tech/laravel-shipper dev-${BRANCH}"
    fi
  fi
}

sync_shipper() {
  local version="$1"
  local versionDir="${FUNC_TEST_DIR}/${version}"

  echo "[${version}] Syncing laravel-shipper..."
  cd "${versionDir}"
  rsync \
    --checksum \
    --archive \
    --exclude=vendor/ \
    --exclude=.git/ \
    --exclude=test/functional \
    "$PROJECT_DIR/" \
    vendor/x3tech/laravel-shipper
}

add_provider() {
  local version="$1"

  echo "[${version}] Adding provider..."
  case "${version}" in
    4.0|4.1|4.2)
      add_provider_4 "${version}"
      ;;
    5.0)
      add_provider_50 "${version}"
      ;;
    5.1)
      add_provider_51 "${version}"
      ;;
  esac
}

add_provider_4() {
  local version="$1"
  local versionDir="${FUNC_TEST_DIR}/${version}"

  local configFile="${versionDir}/app/config/app.php"
  if ! grep 'ShipperProvider' "${configFile}" > /dev/null; then
    sed -i \
      "s/WorkbenchServiceProvider',/WorkbenchServiceProvider', 'x3tech\\\\LaravelShipper\\\\Provider\\\\ShipperProvider',/g" \
      "${configFile}"
  fi
}

add_provider_50() {
  local version="$1"
  local versionDir="${FUNC_TEST_DIR}/${version}"

  local configFile="${versionDir}/config/app.php"
  if ! grep 'ShipperProvider' "${configFile}" > /dev/null; then
    sed -i \
      "s/RouteServiceProvider',/RouteServiceProvider', 'x3tech\\\\LaravelShipper\\\\Provider\\\\ShipperProvider',/g" \
      "${configFile}"
  fi
}

add_provider_51() {
  local version="$1"
  local versionDir="${FUNC_TEST_DIR}/${version}"

  local configFile="${versionDir}/config/app.php"
  if ! grep 'ShipperProvider' "${configFile}" > /dev/null; then
    sed -i \
      "s/RouteServiceProvider::class,/RouteServiceProvider::class, 'x3tech\\\\LaravelShipper\\\\Provider\\\\ShipperProvider',/g" \
      "${configFile}"
  fi
}