export default async (execa) => {
    console.log('\nInstalling ourstage...')

    const npmRegistryToken = process.env.NPM_REGISTRY_TOKEN
    const ourstageEnv = process.env.OURSTAGE_ENV.toLocaleLowerCase()
    const imageName = `${process.env.OURSTAGE_BACKEND_IMAGE_NAME}-${ourstageEnv}:${process.env.OURSTAGE_BACKEND_IMAGE_TAG}`

    const buildArgv = [
        'build',
        `--build-arg=NPM_REGISTRY_TOKEN=${npmRegistryToken}`,
        `--file=./packages/backend/${ourstageEnv}.containerfile`,
        '--network=host',
        `--tag=${imageName}`,
        './',
    ]

    const buildContainerCommandResult = await execa('docker', buildArgv, {
        cleanup: true,
        env: process.env,
        shell: false,
        stderr: process.stderr,
        stdout: process.stdout,
        stripFinalNewline: true,
    })

    if (buildContainerCommandResult.failed) {
        throw new Error('Failed to build the container.')
    }

    console.log('Successfully installed ourstage.')
}
